#!/usr/bin/env python3
"""Enable and select Squirrel Hans via TIS.

Squirrel's own CLI can report Hans as already enabled while TISCreateInputSourceList
(includeAllInstalled=false) still omits the Input Mode. The menu bar then only
shows ABC + the character palette. Enable the source object from the full list.
"""
import ctypes
import ctypes.util
import os
import subprocess
import sys
import time
from ctypes import c_bool, c_char_p, c_int32, c_long, c_uint32, c_void_p

HANS = "im.rime.inputmethod.Squirrel.Hans"
PARENT = "im.rime.inputmethod.Squirrel"
ABC = "com.apple.keylayout.ABC"
QINGJIAN = "app.qingjian.inputmethod"
QINGJIAN_APP_CANDIDATES = (
    os.path.expanduser("~/Library/Input Methods/Qingjian.app"),
    "/Library/Input Methods/Qingjian.app",
)
STRAY_MODES = (
    "com.apple.inputmethod.AinuIM.Ainu",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Japanese",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
)

carbon = ctypes.cdll.LoadLibrary(ctypes.util.find_library("Carbon"))
cf = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreFoundation"))

kCFStringEncodingUTF8 = 0x08000100

TISCreateInputSourceList = carbon.TISCreateInputSourceList
TISCreateInputSourceList.restype = c_void_p
TISCreateInputSourceList.argtypes = [c_void_p, c_bool]
TISGetInputSourceProperty = carbon.TISGetInputSourceProperty
TISGetInputSourceProperty.restype = c_void_p
TISGetInputSourceProperty.argtypes = [c_void_p, c_void_p]
TISEnableInputSource = carbon.TISEnableInputSource
TISEnableInputSource.restype = c_int32
TISEnableInputSource.argtypes = [c_void_p]
TISSelectInputSource = carbon.TISSelectInputSource
TISSelectInputSource.restype = c_int32
TISSelectInputSource.argtypes = [c_void_p]
TISDisableInputSource = carbon.TISDisableInputSource
TISDisableInputSource.restype = c_int32
TISDisableInputSource.argtypes = [c_void_p]
TISRegisterInputSource = carbon.TISRegisterInputSource
TISRegisterInputSource.restype = c_int32
TISRegisterInputSource.argtypes = [c_void_p]

CFArrayGetCount = cf.CFArrayGetCount
CFArrayGetCount.restype = c_long
CFArrayGetCount.argtypes = [c_void_p]
CFArrayGetValueAtIndex = cf.CFArrayGetValueAtIndex
CFArrayGetValueAtIndex.restype = c_void_p
CFArrayGetValueAtIndex.argtypes = [c_void_p, c_long]
CFStringGetCString = cf.CFStringGetCString
CFStringGetCString.restype = c_bool
CFStringGetCString.argtypes = [c_void_p, c_char_p, c_long, c_uint32]
CFStringCreateWithCString = cf.CFStringCreateWithCString
CFStringCreateWithCString.restype = c_void_p
CFStringCreateWithCString.argtypes = [c_void_p, c_char_p, c_uint32]
CFURLCreateWithFileSystemPath = cf.CFURLCreateWithFileSystemPath
CFURLCreateWithFileSystemPath.restype = c_void_p
CFURLCreateWithFileSystemPath.argtypes = [c_void_p, c_void_p, c_long, c_bool]

kID = c_void_p.in_dll(carbon, "kTISPropertyInputSourceID")


def cfstr(ref):
    if not ref:
        return ""
    buf = ctypes.create_string_buffer(1024)
    if CFStringGetCString(ref, buf, 1024, kCFStringEncodingUTF8):
        return buf.value.decode()
    return ""


def find(sid, include_all):
    lst = TISCreateInputSourceList(None, include_all)
    if not lst:
        return None
    n = CFArrayGetCount(lst)
    for i in range(n):
        src = CFArrayGetValueAtIndex(lst, i)
        if cfstr(TISGetInputSourceProperty(src, kID)) == sid:
            return src
    return None


def register_app(path):
    pstr = CFStringCreateWithCString(None, path.encode(), kCFStringEncodingUTF8)
    url = CFURLCreateWithFileSystemPath(None, pstr, 0, True)
    if url:
        TISRegisterInputSource(url)


def qingjian_app():
    for path in QINGJIAN_APP_CANDIDATES:
        if os.path.isdir(path):
            return path
    return None


def ensure_qingjian():
    """青简是 adhoc 签名。TISEnable 在进程没起来时返回 0 却不进会话列表，必须先 open。"""
    app = qingjian_app()
    if app is None:
        return
    register_app(app)
    subprocess.run(["open", app], check=False)
    time.sleep(1)
    src = find(QINGJIAN, True)
    if src is not None:
        TISEnableInputSource(src)


def main():
    parent = find(PARENT, True)
    hans = find(HANS, True)
    abc = find(ABC, True)
    if parent is None or hans is None:
        print("squirrel TIS sources missing", file=sys.stderr)
        return 1
    TISEnableInputSource(parent)
    TISEnableInputSource(hans)
    if abc is not None:
        TISEnableInputSource(abc)
    ensure_qingjian()
    for sid in STRAY_MODES:
        src = find(sid, False)
        if src is not None:
            TISDisableInputSource(src)
    rc = TISSelectInputSource(hans)
    if rc != 0:
        print(f"TISSelectInputSource Hans failed: {rc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
