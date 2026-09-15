# dotfiles

設定ファイルを管理するリポジトリ。

## セットアップ

### 対象ファイルの配置

* リポジトリをクローン、もしくは対象ファイルを任意のパスに配置

### シンボリックリンクの作成

* `{target path}` は参照先ファイルの絶対パス、`{link path}` は作成するリンクの絶対パスに置き換え
* リンクの作成先にファイルがない状態で実行

#### Windows

* Git Bash を「管理者として実行」で起動

```bash
MSYS=winsymlinks:nativestrict ln -s "{target path}" "{link path}"
```

* `MSYS=winsymlinks:nativestrict` はコピーで代用せず、Windows のシンボリックリンクを作成するための指定

#### Mac

```sh
ln -s "{target path}" "{link path}"
```

### シンボリックリンクの確認

```sh
ls -l "{link path}"
```

* `->` の後に参照先ファイルのパスが表示されれば成功
* 必要に応じて設定ファイルの再読み込みを行う
