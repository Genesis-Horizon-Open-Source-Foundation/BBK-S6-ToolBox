import os
import threading
import time
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from queue import Queue
from typing import Optional, Callable, Dict, Any
import hashlib
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DownloadEngine:
    def __init__(self, max_threads: int = 8, chunk_size: int = 1024 * 1024):
        self.max_threads = max_threads
        self.chunk_size = chunk_size
        self.is_downloading = False
        self.is_paused = False
        self.download_info = {}
        self.progress_callbacks = {}
        self.speed_callbacks = {}
        self.complete_callbacks = {}
        self.error_callbacks = {}
        
    def add_progress_callback(self, download_id: str, callback: Callable[[int, int], None]):
        if download_id not in self.progress_callbacks:
            self.progress_callbacks[download_id] = []
        self.progress_callbacks[download_id].append(callback)
        
    def add_speed_callback(self, download_id: str, callback: Callable[[float], None]):
        if download_id not in self.speed_callbacks:
            self.speed_callbacks[download_id] = []
        self.speed_callbacks[download_id].append(callback)
        
    def add_complete_callback(self, download_id: str, callback: Callable[[str], None]):
        if download_id not in self.complete_callbacks:
            self.complete_callbacks[download_id] = []
        self.complete_callbacks[download_id].append(callback)
        
    def add_error_callback(self, download_id: str, callback: Callable[[str, Exception], None]):
        if download_id not in self.error_callbacks:
            self.error_callbacks[download_id] = []
        self.error_callbacks[download_id].append(callback)
        
    def _trigger_callbacks(self, download_id: str, callback_type: str, *args):
        callbacks = getattr(self, f'{callback_type}_callbacks', {}).get(download_id, [])
        for callback in callbacks:
            try:
                callback(*args)
            except Exception as e:
                print(f"Callback error: {e}")
                
    def get_file_size(self, url: str) -> Optional[int]:
        try:
            response = requests.head(url, timeout=10)
            if response.status_code == 200:
                return int(response.headers.get('content-length', 0))
        except Exception as e:
            print(f"获取文件大小失败: {e}")
        return None
        
    def supports_range(self, url: str) -> bool:
        try:
            response = requests.head(url, timeout=10)
            return response.headers.get('accept-ranges') == 'bytes'
        except Exception:
            return False
            
    def download_chunk(self, url: str, start: int, end: int, file_path: str, 
                       chunk_id: int, download_id: str, temp_dir: str = None):
        if temp_dir is None:
            temp_dir = os.path.dirname(file_path)
            
        temp_file = os.path.join(temp_dir, f"{os.path.basename(file_path)}.part{chunk_id}")
        
        headers = {'Range': f'bytes={start}-{end}'}
        
        try:
            response = requests.get(url, headers=headers, stream=True, timeout=30)
            response.raise_for_status()
            
            with open(temp_file, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    if self.is_paused or not self.is_downloading:
                        return
                    f.write(chunk)
                    
                    if download_id in self.download_info:
                        with threading.Lock():
                            self.download_info[download_id]['downloaded'] += len(chunk)
                            downloaded = self.download_info[download_id]['downloaded']
                            total = self.download_info[download_id]['total_size']
                            self._trigger_callbacks(download_id, 'progress', downloaded, total)
                            
        except Exception as e:
            self._trigger_callbacks(download_id, 'error', f"下载块{chunk_id}失败", e)
            raise
            
    def merge_files(self, file_path: str, temp_dir: str = None, num_chunks: int = 0):
        if temp_dir is None:
            temp_dir = os.path.dirname(file_path)
            
        with open(file_path, 'wb') as outfile:
            for i in range(num_chunks):
                chunk_file = os.path.join(temp_dir, f"{os.path.basename(file_path)}.part{i}")
                if os.path.exists(chunk_file):
                    with open(chunk_file, 'rb') as infile:
                        outfile.write(infile.read())
                    os.remove(chunk_file)
                    
    def calculate_md5(self, file_path: str) -> str:
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
        
    def start_download(self, url: str, file_path: str, download_id: str = None,
                      max_threads: int = None, chunk_size: int = None) -> str:
        if download_id is None:
            download_id = f"download_{int(time.time())}"
            
        if max_threads is None:
            max_threads = self.max_threads
        if chunk_size is None:
            chunk_size = self.chunk_size
            
        if os.path.exists(file_path):
            self._trigger_callbacks(download_id, 'error', "文件已存在", None)
            return download_id
            
        total_size = self.get_file_size(url)
        if total_size is None:
            self._trigger_callbacks(download_id, 'error', "无法获取文件大小", None)
            return download_id
        self.download_info[download_id] = {
            'url': url,
            'file_path': file_path,
            'total_size': total_size,
            'downloaded': 0,
            'start_time': time.time(),
            'max_threads': max_threads,
            'chunk_size': chunk_size
        }
        
        self.is_downloading = True
        self.is_paused = False
        
        download_thread = threading.Thread(
            target=self._download_worker,
            args=(download_id,)
        )
        download_thread.daemon = True
        download_thread.start()
        
        return download_id
        
    def _download_worker(self, download_id: str):
        info = self.download_info.get(download_id)
        if not info:
            return
            
        url = info['url']
        file_path = info['file_path']
        total_size = info['total_size']
        max_threads = info['max_threads']
        chunk_size = info['chunk_size']
        
        temp_dir = os.path.dirname(file_path)
        
        try:
            if self.supports_range(url) and total_size > chunk_size:
                chunks = []
                chunk_size_actual = max(chunk_size, total_size // max_threads)
                
                for i in range(max_threads):
                    start = i * chunk_size_actual
                    end = min(start + chunk_size_actual - 1, total_size - 1)
                    if start < total_size:
                        chunks.append((start, end))
                        
                num_chunks = len(chunks)

                with ThreadPoolExecutor(max_workers=max_threads) as executor:
                    futures = []
                    for i, (start, end) in enumerate(chunks):
                        future = executor.submit(
                            self.download_chunk,
                            url, start, end, file_path, i, download_id, temp_dir
                        )
                        futures.append(future)
                        
                    for future in as_completed(futures):
                        future.result()
                        
                self.merge_files(file_path, temp_dir, num_chunks)
                
            else:
                self.download_chunk(url, 0, total_size - 1, file_path, 0, download_id, temp_dir)
                temp_file = os.path.join(temp_dir, f"{os.path.basename(file_path)}.part0")
                if os.path.exists(temp_file):
                    os.rename(temp_file, file_path)
                    
            self._trigger_callbacks(download_id, 'complete', file_path)
            
        except Exception as e:
            self._trigger_callbacks(download_id, 'error', "下载失败", e)
        finally:
            self.is_downloading = False
            
    def pause_download(self, download_id: str = None):
        self.is_paused = True
        
    def resume_download(self, download_id: str = None):
        self.is_paused = False
        
    def cancel_download(self, download_id: str = None):
        self.is_downloading = False
        self.is_paused = False
        
    def get_download_info(self, download_id: str) -> Optional[Dict[str, Any]]:
        return self.download_info.get(download_id)
        
    def get_download_speed(self, download_id: str) -> float:
        info = self.download_info.get(download_id)
        if not info or 'start_time' not in info:
            return 0.0
            
        elapsed = time.time() - info['start_time']
        if elapsed == 0:
            return 0.0
            
        speed = info['downloaded'] / elapsed
        self._trigger_callbacks(download_id, 'speed', speed)
        
        return speed
        
    def get_progress(self, download_id: str) -> float:
        info = self.download_info.get(download_id)
        if not info or info['total_size'] == 0:
            return 0.0
            
        return info['downloaded'] / info['total_size']
        
    def format_speed(self, speed_bytes: float) -> str:
        """格式化下载速度为易读格式"""
        if speed_bytes < 1024:
            return f"{speed_bytes:.1f} B/s"
        elif speed_bytes < 1024 * 1024:
            return f"{speed_bytes / 1024:.1f} KB/s"
        elif speed_bytes < 1024 * 1024 * 1024:
            return f"{speed_bytes / (1024 * 1024):.1f} MB/s"
        else:
            return f"{speed_bytes / (1024 * 1024 * 1024):.1f} GB/s"
            
    def format_size(self, size_bytes: int) -> str:
        """格式化文件大小为易读格式"""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes / 1024:.1f} KB"
        elif size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes / (1024 * 1024):.1f} MB"
        else:
            return f"{size_bytes / (1024 * 1024 * 1024):.1f} GB"
            
    def format_progress(self, download_id: str) -> str:
        """获取格式化的进度信息"""
        info = self.download_info.get(download_id)
        if not info:
            return "无下载信息"
            
        downloaded = min(info['downloaded'], info['total_size'])
        total = info['total_size']
        speed = self.get_download_speed(download_id)
        
        if total == 0:
            return "准备下载..."
            
        progress = min((downloaded / total) * 100, 100)
        if speed > 0 and downloaded < total:
            remaining_bytes = max(total - downloaded, 0)
            remaining_seconds = remaining_bytes / speed
            
            if remaining_seconds < 60:
                remaining_time = f"{remaining_seconds:.0f}秒"
            elif remaining_seconds < 3600:
                remaining_time = f"{remaining_seconds / 60:.1f}分钟"
            else:
                remaining_time = f"{remaining_seconds / 3600:.1f}小时"
        elif downloaded >= total:
            remaining_time = "已完成"
        else:
            remaining_time = "计算中..."
            
        return f"{self.format_size(downloaded)} / {self.format_size(total)} ({progress:.1f}%) | {self.format_speed(speed)} | {remaining_time}"


class ProgressBar:
    """进度条显示类"""
    def __init__(self, width: int = 50):
        self.width = width
        self.last_progress = -1
        self.last_update_time = 0
        
    def update(self, download_id: str, engine: DownloadEngine, force_update: bool = False):
        """更新进度条显示"""
        current_time = time.time()

        if not force_update and current_time - self.last_update_time < 0.1:
            return
            
        info = engine.get_download_info(download_id)
        if not info:
            return
            
        downloaded = info['downloaded']
        total = info['total_size']
        
        if total == 0:
            return
            
        progress = (downloaded / total) * 100

        if not force_update and int(progress) == int(self.last_progress):
            return
            
        self.last_progress = progress
        self.last_update_time = current_time

        filled_width = int(self.width * progress / 100)
        bar = '█' * filled_width + '░' * (self.width - filled_width)

        progress_info = engine.format_progress(download_id)

        print(f"\r[{bar}] {progress_info}", end='', flush=True)

        if progress >= 100:
            print()
            
    def clear(self):
        """清除进度条显示"""
        print('\r' + ' ' * (self.width + 100), end='\r', flush=True)


download_engine = DownloadEngine()


def start_download(url: str, file_path: str, download_id: str = None,
                  max_threads: int = 8, chunk_size: int = 1024 * 1024) -> str:
    return download_engine.start_download(url, file_path, download_id, max_threads, chunk_size)


def pause_download(download_id: str = None):
    download_engine.pause_download(download_id)


def resume_download(download_id: str = None):
    download_engine.resume_download(download_id)


def cancel_download(download_id: str = None):
    download_engine.cancel_download(download_id)


def get_download_info(download_id: str) -> Optional[Dict[str, Any]]:
    return download_engine.get_download_info(download_id)


def get_download_speed(download_id: str) -> float:
    return download_engine.get_download_speed(download_id)


def get_progress(download_id: str) -> float:
    return download_engine.get_progress(download_id)


def add_progress_callback(download_id: str, callback: Callable[[int, int], None]):
    download_engine.add_progress_callback(download_id, callback)


def add_speed_callback(download_id: str, callback: Callable[[float], None]):
    download_engine.add_speed_callback(download_id, callback)


def add_complete_callback(download_id: str, callback: Callable[[str], None]):
    download_engine.add_complete_callback(download_id, callback)


def add_error_callback(download_id: str, callback: Callable[[str, Exception], None]):
    download_engine.add_error_callback(download_id, callback)


def format_speed(speed_bytes: float) -> str:
    """格式化下载速度为易读格式"""
    return download_engine.format_speed(speed_bytes)


def format_size(size_bytes: int) -> str:
    """格式化文件大小为易读格式"""
    return download_engine.format_size(size_bytes)


def format_progress(download_id: str) -> str:
    """获取格式化的进度信息"""
    return download_engine.format_progress(download_id)


class ProgressBar:
    """进度条显示类"""
    def __init__(self, width: int = 50):
        self.width = width
        self.last_progress = -1
        self.last_update_time = 0
        
    def update(self, download_id: str, engine: DownloadEngine = None, force_update: bool = False):
        """更新进度条显示"""
        if engine is None:
            engine = download_engine
            
        current_time = time.time()
        if not force_update and current_time - self.last_update_time < 0.1:
            return
            
        info = engine.get_download_info(download_id)
        if not info:
            return
            
        downloaded = min(info['downloaded'], info['total_size'])
        total = info['total_size']
        
        if total == 0:
            return
            
        progress = min((downloaded / total) * 100, 100)

        if not force_update and int(progress) == int(self.last_progress):
            return
            
        self.last_progress = progress
        self.last_update_time = current_time

        filled_width = min(int(self.width * progress / 100), self.width)
        bar = '█' * filled_width + '░' * (self.width - filled_width)

        progress_info = engine.format_progress(download_id)

        print(f"\r[{bar}] {progress_info}", end='', flush=True)

        if progress >= 100:
            print()
            
    def clear(self):
        """清除进度条显示"""
        print('\r' + ' ' * (self.width + 100), end='\r', flush=True)


def create_progress_bar(width: int = 50) -> ProgressBar:
    """创建进度条实例"""
    return ProgressBar(width)