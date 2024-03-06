# FireFlutter

FireFlutter 는 레고 블록을 쌓아서 작품을 만들 듯이, FireFlutter 가 제공하는 위젯, 모듈 등의 기능들을 통해서 앱을 보다 쉽게 만들 수 있게 해 줍니다.

FireFlutter 를 통해서 채팅, 게시판 및 소셜 커뮤니티 앱을 쉽고 빠르게 만들 수 있게 해 주는 FireFlutter 패키지 설명 문서입니다.

FireFlutter 을 확장하여 쇼핑몰, CMS 등 다양한 앱을 만들 수 있습니다.

## 설치

- See [install.md](install.md)

## 순서


### 활용법

- [빌딩 블록](building_blocks.md)를 참고하시면, fireship 을 통해서 앱을 개발 할 수 있는 방법에 여러가지 설명을 하고 있습니다.
- FireFlutter 의 exmaple 폴더에 예제 코드가 있습니다.

### FireFlutter 의 기본 이해

- FireFlutter 는 데이터베이스 구조와 관련된 로직을 구현하는 코드 뿐만아니라, 플러터 디자인을 위한 위젯들을 같이 제공하고 

- 모든 모델 클래스에는 아래와 같은 변수들을 가지고 있다.
    - `node` 는 데이터 노드 이름을 가지고 있다. 예를 들면, `Post.node` 는 `posts` 의 값을 가지고 있다.
    - 데이터 reference 는 `____Ref` 로 끝난다.
    - `ref` 는 해당 모델의 데이터 reference 이다.
    - `rootRef` 는 Realtime Databsae 의 최상위 `/` 를 가르킨다.
    - `nodeRef` 는 각 데이터 노드의 최 상이 클래스를 가르킨다. 예: `/users`, `/posts`, etc.
    - 참고로 2024년 3월 현재, 이 부분 코드 리팩토링 중이어서 혼동이 조금 있을 수 있다.

- 일부 모델 클래스에는 `onFieldChange` 라는 위젯 빌드 함수가 있으며, 내부적으로 단순히 `Value` 위젯을 사용하여 특정 필드가 변경되면, 위젯을 빌드 할 수 있도록 해 놓았다.


### 빠르게 시작하기

- [빠르게 시작하기](./quick_start.md) 문서 참고

### UI 디자인

- [디자인 문서](./design.md) 참고


## 양해 말씀

- 본 문서는 높임말을 원칙으로 작성이 됩니다. 하지만, 글 솜씨가 부족하여 낮춤말로 표기되거나 설명이 잘 안되는 경우가 많습니다. 문서를 수정 또는 보강해 주실 분을 모십니다.
  신청은 [파이어베이스+플러터 단톡방](https://open.kakao.com/o/gaScS0nf)에서 해 주시면 됩니다.

## 참여

- FireFlutter 에 대한 궁금한 점 및 각종 의견은 [파이어베이스+플러터 단톡방](https://open.kakao.com/o/gaScS0nf)에서 해 주시면 됩니다.