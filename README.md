# post-platform

## Demo
[Video link](https://youtu.be/GbXTjVWnB7Q)

## 介紹
這是一個簡易的區塊鏈貼文系統，使用者可在App介面上撰寫貼文，並送至區塊鏈上做成NFT，隨後便可以透過搜尋Token ID的方式來閱讀鏈上貼文。

## 環境

Solidity：0.8.17

Dart及相關的dependencies版本則在 `./post_system/pubspec.yaml`

## 使用方式

1. 透過Remix IDE將 `./smart_contract/PostSystem.sol` 中的 `PostNFT` 部署至鏈上（test net）。(我是使用[Ganache](https://trufflesuite.com/ganache/))
2. 將 `./post_system/lib/main.dart` 中的 9 ~ 12行，依下列指示修改：
    - `MY_ADDRESS`: 改成部署者的地址
    - `MY_PRIVATE_KEY`: 改成部署者的私鑰
    - `BLOCKCHAIN_URL`: 改成該鏈的url
    - `CONTRACT_ADDRESS`: 改成合約地址
3. 開啟欲使用的模擬器並執行即可。
