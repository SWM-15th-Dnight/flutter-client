# Calinify mobile client repository


## feature/calendar-crud

- feat: monthly view with dummy data
- feat: layout LoginScreen in ratio
- feat: avoid redundancy of _getCalendarList
- feat: display the number of daily events in monthly view

### 1. Read

- [x] _getCalendarList 2번 호출되는 거 고치기

- [x] cals 데이터를 mainCalendar에 주기

- [x] mainCalendar에서 출력 되는지 보기

- [x] 

- [ ] error: LateInitializationError: Field '_calendarData@40460861' has not been initialized.

파싱해서 defaultBuilder에서 날짜 비교, 해당 날짜에 이벤트가 있을 경우 futureBuilder 사용하여 Text 제목 생성

이벤트 스타일 대충 꾸미기

- [ ] 화면에 맞춰서 일정 제목 길이 맞추기

- [ ] 화면과  맞춰서 monthly view에서 보여지는 일정 개수 제한하기

- [ ] 일간 일정리스트 보기

- [ ] 일정 세부내용 보기

### 2. Create

플로팅 버튼 트랜지션 및 클릭 효과

입력해보기 입력테스트

(제목, 날짜, 시간 등 최소한의 데이터만)

### 3. Update & Delete

일정 수정 및 삭제 요청 api 양식에 맞추기

## feature/natural-language-input

- [ ] 지피티 쪽으로 보내서 응답받고 건내 받은 걸 입력폼에 넣기

## feature/stt-input

- [ ] Stt 찾아보기 및 애뮬에서 테스트
