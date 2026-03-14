import os
import subprocess
import torchaudio
from torch.utils.data import Dataset as TorchDataset
from abc import abstractmethod


def preprocess_audio(source, target, sample_rate):
    p = subprocess.Popen(
        ["ffmpeg", "-i", source, "-ar", str(sample_rate), target, "-loglevel", "quiet"]
    )
    p.wait()


class Dataset(TorchDataset):

    _ext_audio = ".wav"

    def __init__(self, root: str):
        pass

    @abstractmethod
    def file_path(self, n: int) -> str:
        pass

    def target_file_path(self, n: int) -> str:
        fp = self.file_path(n)
        file_basename, _ = os.path.splitext(fp)
        return file_basename + self._ext_audio

    def preprocess(self, n: int, sample_rate: int):
        print("Please convert files manually to sample rate:", sample_rate)
        exit()

    def load(self, n):
        # Removed preprocessing here, because it preprocessed files into *.wav files.
        # For large datasets (100s of GBs) this is undesired.
        # It is more efficient to manually preprocess the data into the correct sample rate.
        # torchaudio.load can also handle mp3s.
        target_fp = self.file_path(n)
        audio, sample_rate = torchaudio.load(target_fp)
        return audio, sample_rate
