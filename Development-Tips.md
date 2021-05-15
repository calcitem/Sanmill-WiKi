screen: https://www.jianshu.com/p/e91746ef4058
hwclock: https://blog.csdn.net/iw1210/article/details/78523568

https://stackoverflow.com/questions/36841461/error-android-emulator-gets-killed

# Restore Flutter Engine Crash Stack
https://fucknmb.com/2019/10/20/%E8%8E%B7%E5%8F%96%E5%B9%B6%E8%BF%98%E5%8E%9FFlutter-Engine-Crash%E5%A0%86%E6%A0%88/

patch https://android-review.googlesource.com/c/platform/ndk/+/977970/1/ndk-stack.py#49
and:
```
ndk-stack -sym "src\ui\flutter\build\app\intermediates\cmake\debug\obj\arm64-v8a" -dump *.xcrash

```

# Github action

https://di1shuai.com/%E4%BD%BF%E7%94%A8GithubAction%E5%8F%91%E5%B8%83Flutter%E9%A1%B9%E7%9B%AE.html

# Flash AOSP Image

https://ci.android.com/builds/branches/aosp-master-with-phones-throttled/grid?

download .sh, run, space ACCEPT IT

```shell
fastboot.exe flash bootloader .\bootloader.img
fastboot.exe flash radio .\radio.img
fastboot update ../aosp_redfin_hwasan-flashable-7224646-with-license.zip
```