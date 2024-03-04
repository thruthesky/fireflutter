# FireFlutter

FireFlutter 는 레고 블록을 쌓아서 작품을 만들 듯이, FireFlutter 가 제공하는 위젯, 모듈 등의 기능들을 통해서 앱을 보다 쉽게 만들 수 있게 해 줍니다.

FireFlutter 를 통해서 채팅, 게시판 및 소셜 커뮤니티 앱을 쉽고 빠르게 만들 수 있게 해 주는 FireFlutter 패키지 설명 문서입니다.

FireFlutter 을 확장하여 쇼핑몰, CMS 등 다양한 앱을 만들 수 있습니다.




## 설치

- 설치에 대한 설명


## 활용법

[빌딩 블록](building_blocks.md)를 참고하시면, fireship 을 통해서 앱을 개발 할 수 있는 방법에 여러가지 설명을 하고 있습니다.


## FireFlutter 의 기본 이해



- 모든 모델 클래스에는 아래와 같은 변수들을 가지고 있다.
  - `node` 는 데이터 노드 이름을 가지고 있다. 예를 들면, `Post.node` 는 `posts` 의 값을 가지고 있다.
  - 데이터 reference 는 `____Ref` 로 끝난다.
  - `ref` 는 해당 모델의 데이터 reference 이다.
  - `rootRef` 는 Realtime Databsae 의 최상위 `/` 를 가르킨다.
  - `nodeRef` 는 각 데이터 노드의 최 상이 클래스를 가르킨다. 예: `/users`, `/posts`, etc.
  - 참고로 2024년 3월 현재, 이 부분 코드 리팩토링 중이어서 혼동이 조금 있을 수 있다.


- 일부 모델 클래스에는 `onFieldChange` 라는 위젯 빌드 함수가 있으며, 내부적으로 단순히 `Value` 위젯을 사용하여 특정 필드가 변경되면, 위젯을 빌드 할 수 있도록 해 놓았다.



