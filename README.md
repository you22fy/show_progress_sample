# show_progress_app

API通信の進捗状況を表示するアプリ

# demo

| デモ動画 |
| --- | 
| <video src="https://github.com/user-attachments/assets/051cba43-e73b-4b89-b7b0-5846c5683417"> |



# 動かし方
## webサーバーを起動
Webサーバーは`server/server.dart`を実行します。
```bash
dart run server/server.dart
```

## Flutterアプリを起動
Flutterアプリは`lib/main.dart`を実行します。
どちらもlocalで実行するのでCORSの設定が必要です。
CORSの設定はserver.dartで行なっており、localhost:3000からのアクセスを許可しています。
```bash
flutter run -d web-server --web-port 3000
```
