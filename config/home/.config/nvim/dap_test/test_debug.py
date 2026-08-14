from dataclasses import dataclass
from typing import Optional, Sequence, TypedDict


class Summary(TypedDict):
    sum: float
    average: Optional[float]
    status: str


@dataclass
class NumberRunner:
    numbers: Sequence[int]

    @staticmethod
    def _label_for(doubled: int) -> str:
        return "multiple-of-4" if doubled % 4 == 0 else "other"

    def run(self) -> int:
        total = 0
        for index, value in enumerate(self.numbers, start=1):
            doubled = value * 2
            total += doubled
            label = self._label_for(doubled)

            print(
                "loop",
                index,
                "value",
                value,
                "doubled",
                doubled,
                "label",
                label,
                "total",
                total,
            )

        return total


def safe_divide(left: float, right: float) -> Optional[float]:
    if right == 0:
        return None
    return left / right


def summarize(total: float, count: int) -> Summary:
    average = safe_divide(total, count)

    if average is None:
        status = "invalid"
    elif average > 4:
        status = "large"
    else:
        status = "small"

    return {
        "sum": total,
        "average": average,
        "status": status,
    }


def main() -> None:
    numbers = [1, 2, 3, 4]
    total = NumberRunner(numbers).run()

    result = summarize(total, len(numbers))
    print("summary", result)

    empty_result = summarize(10, 0)
    print("empty_result", empty_result)


if __name__ == "__main__":
    main()
