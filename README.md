# PickupCode

取件码 Live Activity：把取件码钉在锁屏和灵动岛。iOS 16.1+，无签名构建，巨魔 TrollStore 安装。

## 结构

- `PickupCode/` 主 App：输入取件码、启动/结束 Live Activity
- `PickupWidget/` Widget Extension：锁屏卡片 + 灵动岛四态界面
- `.github/workflows/build-ipa.yml`：云端生成工程、无签名编译、打包 IPA、发布 Release

## 本地生成工程

需要 macOS + Xcode：

```
brew install xcodegen
xcodegen generate
open PickupCode.xcodeproj
```
