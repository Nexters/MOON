# MOON
![image](https://user-images.githubusercontent.com/16698414/149632530-e8df82dd-1ca2-46cf-b049-e9e7f3ebc17b.png)





<br>
<br>

---


### Truffle Framework



- Ehtereum 개발 프레임워크
- 개발환경 : node 16.13.2
  - `nvm install node 16.13.2`



<br>



## 시작

### truffle 설치 

`sudo npm install -g truffle`



<br>



### 프로젝트 구조

```
├── contracts : Solidity 컨트랙트 소스 디렉토리
├── migrations : 이더리움 네트워크에 배포(deploy)할 때 사용되는 JavaScript 파일 디렉토리
├── test : Application, Contract 테스트 파일 디렉토리
└── truffle-config.js : truffle 설정 파일 
```

 

<br>



## 주요 명령어



### truffle init

turffle project 생성 





<br>



### truffle create migration {name}

truffle을 통해 contract를 배포하기 위해서는 마이그레이션 작성 필요

마이그레이션이란 contract를 배포하고 변경하는 일련의 과정을 js로 기술한것을 의미



`truffle create migration deploy` 와 같이 deploy 마이그레이션을 생성하면

{timestamp}_deploy.js 와같이 js파일이 생성되며, 이후 배포동작시에 timestamp에 따라 순서대로 배포되는것을 보장함.



**생성된 migration 파일**

```js
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
};
```

- 작성 방법

  - 작성한 contract를 가져와서, deployer.deploy() 함수 호출

     ```js
     const TestA = artifacts.require("./TestA.sol");
     const TestB = artifacts.require("./TestB.sol");
     module.exports = function (deployer) {
         deployer.deploy(TestA);
     	  deployer.deploy(TestB);
     };
  ```

  - 만약 컨트랙간에 의존성이 있다면? (특정 컨트랙의 주소를 알아야 배포 가능한 컨트랙이 있는경우 )

    ```js
    const A = artifacts.require("./A.sol");
    const Asub = artifacts.require("./Asub.sol");
    module.exports = function (deployer) {
        deployer.deploy(A).then(function() {
          deployer.deploy(Asub, A.address);
        });
    };
    ```

    > then()을 통해 배포 직후 수행할 다른 작업을 명시
    >
    > - Asub의 생성자 인자가 있다면 `deployer.deploy({배포할컨트랙}, {생성자인자1}, {생성자인자2}, ...)`



<br>



### truffle compile & truffle migrate

contract배포를 위해서는 **Compile, Migrate** 두 과정이 필요함.



**Compile** : solidity contract -> EVM byteCode로 변환하는 과정

**Migrate** : 작성한 마이그레이션 실행을 통해 실제 블록체인 네트워크에 배포하는 과정 



여기서 Compile과정은 `truffle compile` 명령어를 통해 수행

컴파일의 결과로 `build/contracts` 디렉토리 내에 각 contract이름에 해당하는 json 파일이 생성되는데,

이 파일은 배포를 위한 모든 정보를 담고 있음.



<br>





### truffle console & truffle develop



contract 수행 및 테스트, 디버깅을 위해 사용 (둘 다 동일한 목적으로 사용한다)

web3 라이브러리가 사용가능하며, 이더리움 클라이언트에 연결되도록 설정된다.



- console 사용
  - 이미 사용 중인 클라이언트가 있는경우(예: Ganache 또는 geth)
  - 테스트넷(또는 기본 이더리움 네트워크)으로 배포하는 경우
  - 특정 니모닉 또는 계정 목록을 사용하는 경우
- develop 사용
  - truffle 내부에서 ganache cli를 통해 로컬 블록체인 노드 환경을 임의로 만들어줌
  - 특정 계정을 사용할 필요가 없는 경우



#### 사용 가능 명령

- `build`
- `compile`
- `create`
- `debug`
- `deploy`
- `exec`
- `help`
- `install`
- `migrate`
- `networks`
- `opcode`
- `publish`
- `run`
- `test`
- `version`









### truffle deploy 

> `truffle deploy` alias `truffle migrate`

```bash
truffle deploy --network baobab  # testnet

truffle deploy --network cypress # mainnet
```





## Ganache

Ganache란 테스트 목적을 위해 여러분의 PC에 설치해서 사용할 수 있는 로컬 블록체인 플랫폼

네트워크와의 연결이 필요없이 로컬에서 작동하며 contract를 손쉽게 배포, 테스트해볼 수 있음


