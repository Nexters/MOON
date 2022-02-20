# Contract Interface



<br>

## CookieContract (KIP17)

- CALL : 블록체인 데이터 조회 함수
- TRANSACTION : 블록체인 데이터 변경 함수 => 지갑 서명 필요 및 수수료 부과됨


<br>

### [CALL] 쿠키 기본 정보 조회 (cookieId 소유자만 호출 가능)

```solidity
function getCookieInfo(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id

**Response**

- string title : 쿠키 타이틀
- string metaUrl : 쿠키 메타정보(image, description 등..)를 담고있는 url
- string tag : 쿠키 태그
- address creator : 생성자 지갑 주소
- createdAt : 생성 시간(unix timestamp)
<br>




### [CALL] 컨텐츠 조회 (cookieId 소유자만 호출 가능)

```solidity
function getContent(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id

**Response**

- string content : 쿠키에 기록된 컨텐츠 



<br>



### [CALL] 쿠키 생성에 필요한 hammer 값 조회

```solidity
function mintingPriceForHammer()
```

**Response**

- uint256 amount : 쿠키 생성에 필요한 hammer 값



<br>



### [CALL] 쿠키 생성에 필요한 klaytn 값 조회

```solidity
function mintingPriceForKlaytn()
```

**Response**

- uint256 : 쿠키 생성에 필요한 klaytn 값



<br>



### [CALL] 소유한 쿠키 조회

```solidity
function getOwnedCookieIds()
```

**Response**

- uint256[] : msg.sender의 소유한 cookieId 값



<br>



### [CALL] 소유한 쿠키 갯수 조회

```solidity
function balanceOf(address owner)
```

**Params**

- address owner : 지갑 주소



**Response**

- uint256 : owner의 총 쿠키 보유 갯수



<br>



### [CALL] 특정 쿠키 숨김 여부 조회

> 안쓰이는 기능으로 생각

```solidity
function hideCookies(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id



**Response**

- bool : 숨김 여부



<br>



### [CALL] 특정 쿠키 판매 여부 조회

```solidity
function saleCookies(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id



**Response**

- bool : 판매 여부



<br>



### [CALL] 쿠키 판매 가격 조회

```solidity
function cookieHammerPrices(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id



**Response**

- uint256 : 해당 쿠키의 판매 망치 가격



<br>



### [CALL] 쿠키 index로 cookieId 조회

```solidity
function tokenByIndex(uint256 index)
```

**Params**

- uint256 index : 쿠키 index

  > index : 쿠키 소유하게된 순서 값
  >
  > 예를들어 cookie 최초 생성시 cookieId가 123 일 경우 `tokenByIndex(0) => 123`
  >
  > 이후에 cookieId 1000 을 구매하게되면 `tokenByIndex(1) => 1000`
  >
  > 이후에 최초생성한 쿠키(cookieId=123) 을 burn(삭제) 하게 되면 `tokenByIndex(0) => 1000`



**Response**

- uint256 : cookieId(쿠키 고유 id)



<br>



### [CALL] 총 쿠키 발행량

```solidity
function totalSupply()
```

**Response**

- uint256 : 총 쿠키 발행량



<br>



### [TRANSACTION] 가격 변경 (cookieId 소유자만 호출 가능)

```solidity
function changeHammerPrice(uint256 cookieId, uint256 hammerPrice)
```

**Params**

- uint256 cookieId : 쿠키 고유 id
- uint256 hammerPrice : 변경될 hammer 가격



<br>



### [TRANSACTION] 쿠키 숨기기 (cookieId 소유자만 호출 가능)

> 안쓰이는 기능으로 생각 => 백엔드에서 지원하는 API 사용해!

```solidity
function hideCookie(uint256 cookieId, bool isHide)
```

**Params**

- uint256 cookieId : 쿠키 고유 id
- bool isHide
    - true : 숨기기
    - false : 보이기



<br>



### [TRANSACTION] 쿠키 판매 설정 (cookieId 소유자만 호출 가능)

```solidity
function saleCookie(uint256 cookieId, bool isSale)
```

**Params**

- uint256 cookieId : 쿠키 고유 id
- bool isSale
    - true : 판매하기
    - false : 판매중지



<br>



### [TRANSACTION] 쿠키 삭제(cookieId 소유자만 호출 가능)

```solidity
function burnCookie(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id



<br>





### [TRANSACTION] 쿠키 발행 (망치로)

> 소유자의 hammercoin이 mintingPriceForHammer 값 만큼 소모됨 (해당 hammercoin만큼 소유하고있지 않을시 호출 불가)
>
> 해당 메소드 호출 이후 자동으로 판매 설정됨

```solidity
function mintCookieByHammer(string title, string content, string imageUrl, string tag, uint256 hammerPrice)
```

**Params**

- string title : 쿠키 제목
- string content : 쿠키 내용
- string imageUrl : 쿠키 대표이미지
- string tag : 쿠키 태그(카테고리)
- uint256 : 쿠키 최초 판매 가격(해머 가격)



**Response**

- uint26 : 발행된 cookieId



<br>



### [TRANSACTION] 쿠키 발행 (클레이튼으로)

> value에 mintingPriceForKlaytn 만큼 전송해야함(msg.value >= hammerPrice 만족하지 않을시 호출 불가)
>
> 해당 메소드 호출 이후 자동으로 판매 설정됨

```solidity
function mintCookieByKlaytn(string title, string content, string imageUrl, string tag, uint256 hammerPrice)
```

**Params**

- string title : 쿠키 제목
- string content : 쿠키 내용
- string imageUrl : 쿠키 대표이미지
- string tag : 쿠키 태그(카테고리)
- uint256 : 쿠키 최초 판매 가격(해머 가격)



**Response**

- uint26 : 발행된 cookieId



<br>



### [TRANSACTION] 쿠키 구매 (망치로)

> 쿠키가격만큼 hammercoin 소유하고있지 않을 시 호출 불가

```solidity
function buyCookie(uint256 cookieId)
```

**Params**

- uint256 cookieId : 쿠키 고유 id



<br>



<br>



## HammerContract (KIP7)



<br>

### [TRANSACTION] maxApprove
> uint256.MAX_VALUE 
Cookie Contract에 쿠키 거래 총량 제어 승인

<br>

### [TRANSACTION] Approve

> Cookie Contract에서 쿠키 거래를 위해 필요한 제어 승인 과정

```solidity
function approve(address spender, uint256 value)
```

**Params**

- address spender : hammer coin에 대한 제어권을 넘겨줄 주소

  > `CookieContract address` 를 넣어주어야함.

- uint256 amount : 얼마만큼의 제어 가능하게 할 것 인지

  > 해당 값만큼 쿠키 거래시에 망치를 사용가능함.





<br>

### [CALL] Allowance

```solidity
function allowance(address owner, address spender)
```

- **Params**

    - address owner : hammer coin 소유자

    - address spender : owner가 hammer coin에 대한 제어권을 넘겨준 주소



- Response

    - uint256 : spender가 제어가능한 owner의 hammer 량

      > 즉 이 값이 쿠키 가격보다 낮을경우, CookieContract을 통한 쿠키 거래가 불가능함 (transaction 수행시 에러 원인이 됨)
      >
      > 따라서, 클라이언트는 쿠키 구매 이전에 해당 값을 참조해야 할 수 있음





<br>




### [CALL] 총 Hammer 발행량

```solidity
function totalSupply()
```

- **Response**

    - uint256 : 총 쿠키 발행량





<br>


