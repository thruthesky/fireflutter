# Typesense 풀텍스트 검색

- 24년 4월 이후, RTDB 의 글, 코멘트를 Firestore 로 미러링하도록 했다. 즉, Firestore 의 Extensions 를 사용 할 수 있으므로, 더 이상 Typesense 관련 Cloud 함수를 직접 설치하여 사용 할 필요가 없어진 것이다. 굳이 Typesense 뿐만 아니라, Firestore 관련 다른 3rd party Extentensions 쉽게 사용 할 수 있다. 3rd party 검색 엔진을 예로 든다면 Typesense 외에 Algoria, Meilisearch 등을 Extensions 으로 연결해서 쓰면 된다.

- 이 문서에서는 Typesense 에 대해서 설명을 하지만, 원한다면 Typesense 가 아닌 다른 검색 엔진을 사용해도 된다.
  - Typesense 가 완전한 오픈 소스여서 다른 검색엔진 대신 사용한다. 특히, self hosting 으로 검색 엔진을 운영하고자 하는 경우 Typesense 가 적당하다고 판단한다.

- 만약, 수동 backfill 을 해야 한다면, 클라우드 함수 중 `mirrorBackfillRtdbToFirestore` 을 사용하면 된다. 

- 글과 코멘트를 하나의 스키마에 저장한다. 그래서 글과 코멘트를 동시에 검색할 수 있으며 따로 검색 할 수도 있다.
  - 글의 경우, `title` 필드에 값이 있고, `commentId` 필드에 값이 없다.
  - 반대로 코멘트의 경우, `title` 필드에 값이 없고, `commentId` 필드에 값이 있다.
  이러한 차이점을 통해서 글과 코멘트를 구분해야하며, 검색을 따로 할 수도 있다.

## 설치

- 우선, 클라우드 함수 중에서 `userMirror`, `postMirror`, `commentMirror` 를 설치한다. 이 함수들은 RTDB 의 데이터를 Firestore 로 미러링한다.

- 그리고, Firebase Extensions 에서 Typesense 를 아래의 Firestore 경로에 설치를 한다.
  - `users` 경로에 필드는 `birthDay,birthMonth,birthYear,createdAt,displayName,gender` 와 같이 한다.
  - `posts` 경로에 필드는 `uid,postId,category,title,content,createdAt` 와 같이 한다.
  - `comments` 경로에 필드는 `uid,postId,commentId,category,title,content,createdAt` 와 같디 한다.
  위 세개의 extensions 설정에 timeout secodns 를 20 으로 해 준다.

- 그리고, Typeesnse 서버 설정을 한다.
  - Typesense 서버는 클라우드 서비스를 이용해도 되고, 
  - 직접 자신의 서버에 설치해서 운영해도 된다.

- 그리고, Typesense 에 스키마 생성을 한다. 기본적으로 아래와 같이 auto 생성을 하면 된다.

  - 사용자 정보를 색인하는 스키마
```json
{
  "name": "silbusUsers",  
  "fields": [
    {"name": ".*", "type": "auto" }
  ]
}
```

  - 게시글과 코멘트 정보를 색인하는 스키마
```json
{
  "name": "silbusForum",  
  "fields": [
    {"name": ".*", "type": "auto" }
  ]
}
```

- 그리고 사용자, 글, 코멘트 수정을 해서 Typesense 에 색인이 잘 되는지 확인한다.



## 플러터 프론트 엔드에서 검색

### 클라이언트 설정하기

- 아래와 같이 초기화를 한다.

```dart
TypesenseService.instance.init(
    apiKey: 'xxxx',
    scheme: 'http',
    host: 'xxxx.com',
    port: 8108,
    userSchema: 'silbusUsers',
    forumSchema: 'silbusForum'
);
```


### 글 검색하기


아래는 코멘트를 빼고 글만 검색하는 것이다. 참고로 검색 파라메타는 [Typesense 공식 문서 - Search Parameters](https://typesense.org/docs/26.0/api/search.html#search-parameters) 를 참고한다.


```dart
final searchParameters = {
    'q': 'Search keyword',
    'query_by': 'title,content',
    'filter_by': 'category:=discussion',
    'page': '1',
    'per_page': '10',
    'sort_by': 'createdAt:desc'
};

final re = await TypesenseService.instance.searchPosts(searchParameters: searchParameters);

final itemsResult = re.getDocs;

return ListView.builder(
    itemCount: itemsResult.length,
    itemBuilder: (context, index) {
        final resDoc = itemsResult[index];
        if (resDoc.type == TypesenceDocType.user) {
            final user = UserModel.fromJson(resDoc.toJson());
            return Text("User uid: ${user.uid}");
        }
        if (resDoc.type == TypesenceDocType.post) {
            final post = Post.fromJson(resDoc.toJson(), id: resDoc.id);
            return PostListTile( post: post );
        }
        if (resDoc.type == TypesenceDocType.comment) {
            final comment = Comment.fromMap(resDoc.toJson(), resDoc.id, category: resDoc.category ?? '', postId: resDoc.postId ?? '');
            return Text("Comment id: ${comment.id}");
        }
        return Text("Error: document is not form user, post, or comment");
    }
);    
```
