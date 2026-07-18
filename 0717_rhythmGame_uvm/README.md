# Rhythm Game UVM 트러블슈팅

## 1. 문제 현상

`rhythmGame_perfect_test`만 실행했는데 기대와 달리 `miss`가 발생했다.

실행 명령은 다음과 같다.

```bash
make sim TC=rhythmGame_perfect_test
```

로그에서는 손 입력을 넣은 시점에도 판정 출력이 모두 0이었다.

```text
Mon 수집 완료: lane_data=0x0 region=0x1 | perf=0 good=0 miss=0 score=0
```

이후 테스트를 반복 실행하면 scoreboard에 `Miss`가 기록됐다.

처음에는 테스트 이름이 `perfect_test`인데 왜 Miss가 발생하는지 의문이 들 수 있다. 그러나 UVM 테스트 이름은 기대하는 시나리오를 나타낼 뿐, DUT 출력을 Perfect로 강제하지 않는다. DUT가 실제 Perfect 조건을 만족하는 입력을 받지 못하면 Good 또는 Miss를 출력하는 것이 정상이다.

## 2. 로그에서 먼저 확인한 내용

Driver 로그에는 다음 출력이 계속 반복됐다.

```text
[IDLE_FRAME] lane_data=0000 region=0000
```

Monitor 로그는 약 2클럭마다 출력됐고 대부분 다음과 같았다.

```text
perf=0 good=0 miss=0 score=0
```

손을 누른 transaction에서는 다음 로그가 보였다.

```text
[USER_TAP] lane_data=0000 region=0001
```

여기에서 다음과 같이 생각했다.

1. Driver가 `region=1`을 전송한 사실은 확인된다.
2. 하지만 Monitor가 관찰한 DUT 판정은 계속 0이다.
3. 따라서 단순히 sequence가 실행되지 않은 문제는 아니다.
4. 손 입력과 DUT의 판정 시점이 서로 맞지 않거나, 레인 비트가 서로 다르게 해석되고 있을 가능성이 크다.
5. 반복 실행 중 Miss가 나왔다면, 앞에서 입력한 노트가 정상적으로 판정되지 않은 채 계속 내려가 판정 구간을 통과했을 가능성이 크다.

## 3. 원인 1: 로그에 `v_sync`가 표시되지 않음

기존 `convert2string()`은 `note_start`와 `region`만 보고 로그 태그를 결정했다.

```systemverilog
if (note_start && region != 4'b0000)
    event_tag = "NOTE_AND_HIT";
else if (note_start)
    event_tag = "NOTE_START";
else if (region != 4'b0000)
    event_tag = "USER_TAP";
else
    event_tag = "IDLE_FRAME";
```

이 코드에서는 실제 프레임 판정을 발생시키는 `v_sync`가 1인지 0인지 알 수 없다. 따라서 `v_sync=1`인 transaction과 `v_sync=0`인 transaction이 모두 `IDLE_FRAME`으로 표시됐다.

문제를 정확히 관찰하기 위해 로그를 다음처럼 변경한다.

```systemverilog
function string convert2string();
    string event_tag;

    if (note_start && region != 4'b0000)
        event_tag = "NOTE_AND_HIT";
    else if (note_start)
        event_tag = "NOTE_START";
    else if (region != 4'b0000)
        event_tag = "USER_TAP";
    else if (v_sync)
        event_tag = "FRAME_HIGH";
    else
        event_tag = "FRAME_TICK";

    return $sformatf(
        "[%s] v_sync=%b note_start=%b lane_data=%b region=%b main_state=%b",
        event_tag, v_sync, note_start, lane_data, region, main_state
    );
endfunction
```

> RTL의 실제 판정 펄스는 `v_sync=1`일 때가 아니라 `1 -> 0`으로 내려가는 순간 발생한다. 따라서 여기서 `FRAME_TICK`은 `v_sync=0` transaction을 구분하기 위한 로그 이름이다.

## 4. 원인 2: 판정 순간에 손 입력이 이미 0이 됨

### 4.1 RTL의 판정 시점

`GameResult.sv`에서는 다음 코드로 프레임 판정 시점을 만든다.

```systemverilog
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        v_sync_d <= 1'b1;
    else
        v_sync_d <= v_sync;
end

wire frame_tick = !v_sync && v_sync_d;
```

`frame_tick` 조건을 표로 나타내면 다음과 같다.

| 이전 `v_sync_d` | 현재 `v_sync` | `frame_tick` |
|---:|---:|---:|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 1 | 0 |
| 1 | 0 | 1 |

즉, DUT는 `v_sync`가 `1 -> 0`으로 바뀌는 클럭에서만 손 입력과 노트 위치를 판정한다.

### 4.2 기존 sequence의 문제

기존 `press_region()`은 다음 순서로 transaction을 보냈다.

```systemverilog
// 첫 번째 transaction
item.region = region_val;
item.v_sync = 1'b1;

// 두 번째 transaction
item.region = 4'b0000;
item.v_sync = 1'b0;
```

시간 순서로 보면 다음과 같다.

| Transaction | `v_sync` | `region` | DUT 판정 여부 |
|---|---:|---:|---|
| 손 입력 시작 | 1 | 1 | 판정하지 않음 |
| `v_sync` 하강 | 0 | 0 | 판정하지만 손이 없음 |

손을 입력한 transaction에서는 `frame_tick=0`이고, 실제 `frame_tick=1`인 transaction에서는 이미 `region=0`이다. 따라서 DUT가 손 입력을 인식하지 못한다.

### 4.3 수정 방법

`v_sync`가 0으로 내려가는 transaction까지 `region`을 유지하고, 그 다음 transaction에서 손을 해제한다.

```systemverilog
task press_region(bit [3:0] region_val);
    rhythmGame_seq_item item;

    // 1. 손을 누르고 v_sync를 High로 만든다.
    item = rhythmGame_seq_item::type_id::create("press_high");
    start_item(item);
    item.note_start = 1'b0;
    item.lane_data  = 4'b0000;
    item.region     = region_val;
    item.v_sync     = 1'b1;
    item.main_state = 3'b011;
    finish_item(item);

    // 2. v_sync 하강 에지에서도 손 입력을 유지한다.
    //    DUT는 이 transaction에서 판정한다.
    item = rhythmGame_seq_item::type_id::create("press_tick");
    start_item(item);
    item.note_start = 1'b0;
    item.lane_data  = 4'b0000;
    item.region     = region_val;
    item.v_sync     = 1'b0;
    item.main_state = 3'b011;
    finish_item(item);

    // 3. 판정이 끝난 뒤 손 입력을 해제한다.
    item = rhythmGame_seq_item::type_id::create("press_release");
    start_item(item);
    item.note_start = 1'b0;
    item.lane_data  = 4'b0000;
    item.region     = 4'b0000;
    item.v_sync     = 1'b0;
    item.main_state = 3'b011;
    finish_item(item);
endtask
```

수정 후 기대되는 시간 순서는 다음과 같다.

| Transaction | `v_sync` | `region` | DUT 판정 여부 |
|---|---:|---:|---|
| 손 입력 시작 | 1 | 1 | 판정하지 않음 |
| `v_sync` 하강 | 0 | 1 | 손 입력을 포함하여 판정 |
| 손 입력 해제 | 0 | 0 | 판정하지 않음 |

## 5. 원인 3: Perfect 판정 위치와 대기 프레임 수가 맞지 않음

### 5.1 RTL의 이동 거리

`line_count.sv`에서 한 프레임마다 노트의 Y 좌표를 2씩 증가시킨다.

```systemverilog
parameter [1:0] LINE_VALUE = 2;

if (r_en0 && w_vs_dly0_f)
    r_lcnt0 <= r_lcnt0 + LINE_VALUE;
```

따라서 대략적인 노트 위치는 다음 식으로 계산할 수 있다.

```text
노트 Y 위치 = wait_frames 횟수 x LINE_VALUE
```

### 5.2 RTL의 판정 범위

`GameResult.sv`의 판정 범위는 다음과 같다.

```systemverilog
ZONE_MIN    = 385;
PERFECT_MIN = 405;
PERFECT_MAX = 445;
ZONE_MAX    = 465;
```

| Y 위치 | 판정 |
|---:|---|
| 0 ~ 384 | 판정 구역 전 |
| 385 ~ 404 | Good |
| 405 ~ 445 | Perfect |
| 446 ~ 465 | Good |
| 466 이상 | 입력하지 않았다면 Miss |

### 5.3 기존 Perfect sequence 계산

기존 코드는 100프레임을 기다렸다.

```systemverilog
send_note(4'b0001);
wait_frames(100);
press_region(4'b0001);
```

예상 Y 위치는 다음과 같다.

```text
100 frame x 2 line/frame = Y 200
```

Y=200은 Perfect 구간인 405~445보다 훨씬 위다. 따라서 이 시점에 손 입력을 넣어도 Perfect가 발생할 수 없다.

Perfect 구간에 필요한 프레임 수는 다음과 같다.

```text
최소: 405 / 2 = 202.5 -> 약 203 frame
최대: 445 / 2 = 222.5 -> 약 222 frame
중앙: 425 / 2 = 212.5 -> 약 212~213 frame
```

중앙 부근을 목표로 다음과 같이 변경할 수 있다.

```systemverilog
send_note(4'b0001);
wait_frames(212);
press_region(/* 레인 매핑에 맞는 region 값 */);
wait_frames(10);
```

Nonblocking assignment와 clocking block의 샘플링 시점 때문에 실제 판정 좌표에는 한 프레임 정도 차이가 생길 수 있다. 최종적으로는 Monitor에 `o_lcnt0`를 추가해 손 입력이 들어간 정확한 Y 좌표를 확인하는 것이 가장 안전하다.

## 6. VGA 설계에 따른 `lane_data`와 `region`의 비트 방향

이 프로젝트에서는 VGA 화면의 좌우 방향과 카메라 입력의 레인 방향을 맞추기 위해 `lane_data`와 `region`의 비트 순서를 의도적으로 반대로 설계했다. 따라서 이 반전은 버그가 아니라 지켜야 하는 인터페이스 사양이다.

RTL 주석에 따르면 두 신호의 화면 방향은 다음과 같이 서로 다르다.

```text
노트 위치(pos) : 왼쪽부터 pos[3] ... pos[0]
카메라(region): 왼쪽부터 region[0] ... region[3]
```

그래서 `GameResult.sv`에서는 VGA에 표시되는 노트와 카메라 영역이 같은 물리 위치를 가리키도록 카메라 입력 순서를 의도적으로 반전한다.

```systemverilog
wire [3:0] judge_region = {
    lane0_hand_pressed,
    lane1_hand_pressed,
    lane2_hand_pressed,
    lane3_hand_pressed
};
```

SystemVerilog concatenation에서 첫 번째 값은 최상위 비트 `[3]`에 들어간다. 따라서 매핑은 다음과 같다.

| 카메라 입력 | 내부 `judge_region` |
|---|---|
| `region[0]` | `judge_region[3]` |
| `region[1]` | `judge_region[2]` |
| `region[2]` | `judge_region[1]` |
| `region[3]` | `judge_region[0]` |

문제는 RTL의 반전이 아니라, 현재 sequence가 이 VGA 매핑 규칙을 적용하지 않고 두 입력에 동일한 값을 사용한다는 점이다.

```systemverilog
send_note(4'b0001);
press_region(4'b0001);
```

VGA 반전 매핑에 따르면 `lane_data=0001`과 대응하는 카메라 입력은 `region=1000`이다.

```systemverilog
send_note(4'b0001);
press_region(4'b1000);
```

테스트에서 실수하지 않도록 변환 함수를 두는 방법도 있다.

```systemverilog
function automatic bit [3:0] note_lane_to_region(bit [3:0] lane);
    return {lane[0], lane[1], lane[2], lane[3]};
endfunction
```

사용 예시는 다음과 같다.

```systemverilog
bit [3:0] lane = 4'b0001;

send_note(lane);
wait_frames(212);
press_region(note_lane_to_region(lane));
```

따라서 `GameResult.sv`의 `judge_region` 연결은 수정하지 않는다. 테스트벤치에서 노트 레인을 카메라 레인 값으로 변환하는 것이 올바른 수정 방향이다.

4비트 전체 매핑은 다음과 같다.

| VGA 노트 `lane_data` | 대응 카메라 `region` |
|---|---|
| `0001` | `1000` |
| `0010` | `0100` |
| `0100` | `0010` |
| `1000` | `0001` |

여러 레인이 동시에 활성화된 경우에도 같은 방식으로 네 비트의 순서를 뒤집는다. 예를 들어 `lane_data=0011`이면 대응하는 카메라 입력은 `region=1100`이다.

## 7. 왜 10회 반복할 때 뒤늦게 Miss가 나왔는가

Perfect test를 한 번 실행했을 때 Y=200에서 입력하면 아직 Miss 구간까지 가지 않는다. 그래서 즉시 Perfect도 Miss도 발생하지 않을 수 있다.

하지만 테스트를 10회 반복하면 이전 반복에서 생성한 노트도 활성 상태로 계속 내려간다.

예를 들어 각 반복에서 약 110프레임이 진행된다고 가정하면 첫 노트의 위치는 다음과 같이 변한다.

```text
1회차 종료: 약 110 x 2 = Y 220
2회차 진행: 이전 노트가 계속 이동하여 Y 466 이상 도달
```

`GameResult.sv`에서는 Y 좌표가 `ZONE_MAX=465`를 초과하고 입력이 완료되지 않았으면 Miss를 발생시킨다.

```systemverilog
wire passed = (lcnt_y > ZONE_MAX);

if (all_lanes_complete) begin
    // Perfect 또는 Good
end else if (passed) begin
    miss <= 1'b1;
end
```

따라서 관찰한 Miss는 “Perfect test가 Miss를 강제로 생성했다”는 의미가 아니다. 앞선 반복에서 잘못된 타이밍 또는 잘못된 레인으로 입력하여 판정되지 않은 노트가 다음 반복 중 Y=465를 넘어가면서 자연스럽게 Miss가 된 것이다.

## 8. 권장 수정 순서

한 번에 여러 부분을 바꾸면 어떤 변경이 효과가 있었는지 알기 어렵다. 다음 순서로 확인하는 것이 좋다.

1. Driver 로그에 `v_sync`, `note_start`, `main_state`를 추가한다.
2. Monitor가 `o_lcnt0`와 실제 판정 신호를 출력하도록 한다.
3. `press_region()`에서 `v_sync` 하강 에지까지 `region`을 유지한다.
4. Perfect 대기 시간을 약 212프레임으로 조정한다.
5. VGA 물리 레인 정의에 따라 `lane_data=0001`에 대해 `region=1000`을 입력한다. RTL의 `judge_region` 반전은 유지한다.
6. 먼저 반복 없이 Perfect test를 한 번 실행한다.
7. 한 번의 판정이 정상임을 확인한 뒤 10회 반복한다.

## 9. 수정 후 확인해야 할 로그

최소한 다음 정보가 한 줄에 같이 보여야 한다.

```text
v_sync, region, lane_data, o_lcnt0, perfect, good, miss, score
```

성공적인 Perfect 판정의 예시는 다음과 같은 형태다.

```text
v_sync=0 region=1000 lane_data=0000 lcnt0=424 perfect=1 good=0 miss=0 score=...
```

핵심 확인 조건은 다음과 같다.

- `v_sync` 하강 에지에서 손 입력이 0이 아니어야 한다.
- 손 입력 비트가 노트의 레인 비트와 물리적으로 대응해야 한다.
- 해당 노트의 Y 좌표가 405~445 범위에 있어야 한다.
- 같은 노트에서 Perfect가 발생한 뒤 나중에 Miss가 다시 발생하지 않아야 한다.

## 10. 결론

이번 문제는 테스트 이름이나 UVM 자체의 문제가 아니라, 테스트벤치가 만든 입력과 RTL이 판정하는 조건이 맞지 않아 발생했다.

원인 분석의 핵심 근거는 다음 세 가지였다.

1. RTL은 `v_sync`의 하강 에지에서만 판정한다.
2. 기존 sequence는 그 하강 에지에서 `region`을 0으로 내렸다.
3. `wait_frames(100)`의 예상 위치는 Y=200으로 Perfect 범위 405~445에 도달하지 않는다.

여기에 VGA 설계의 레인 비트 반전 규칙까지 테스트벤치에서 맞춰야 올바른 Perfect 판정을 받을 수 있다. RTL의 비트 반전은 의도된 사양이므로 제거하지 않는다. 로그에는 단순히 `USER_TAP`이라는 이름만 출력하기보다 판정 근거가 되는 `v_sync`, 노트 위치, 레인 비트와 결과 신호를 함께 기록해야 같은 문제를 빠르게 추적할 수 있다.
