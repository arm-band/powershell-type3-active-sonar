# Type 3 Active Sonar (三式水中探信儀)

## Abstract

日時フォーマット付きで ping を投げ続け、結果をテキストファイルに出力するスニペットです。

## Result's sample

ファイルに出力される結果は以下のようなフォーマットになります。

```
yyyy/MM/dd hh:ii:ss 192.0.2.1 に ping を送信しています 32 バイトのデータ:
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =3ms TTL=128
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =4ms TTL=128
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =4ms TTL=128
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =4ms TTL=128
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =3ms TTL=128
yyyy/MM/dd hh:ii:ss 192.0.2.1 からの応答: バイト数 =32 時間 =3ms TTL=128
```

## Usage

1. `config.json.sample` をコピーして `config.json` を作成してください
2. 適宜設定を変更してください
    - `address`: ping を送信する宛先
        - 手動で Ctrl + C で強制終了するか、端末の再起動などで**プロセスが終了しない限り ping を投げ続ける**ので、**第三者の迷惑にならない宛先を指定してください**
    - `resultOutput`: ファイル出力先パス・ファイル名
        - `path`: ファイル出力先のフォルダ名。デフォルトは `result`
        - `baseFilename`: ファイル出力先のベースファイル名。デフォルトは `result` で、末尾にハイフン + 年月日8ケタ + `.log` が付く。そのため、ファイル名は `result-yyyyMMdd.log` となる。
3. `start.bat` を実行
4. 確認が完了した任意のタイミングで、コマンドプロンプトを Ctrl + C 等で終了させる