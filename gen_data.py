import random

# 設定參數
CHAN_NUM = 8
DATA_WIDTH = 16
N_PAT = 10  # 測試 10 筆資料
FILENAME = "IN.DAT"
DIR = 0  # 0: 升序, 1: 降序

def generate_data():
    inputs = []
    goldens = []

    for _ in range(N_PAT):
        # 隨機產生一組長度為 CHAN_NUM 的資料
        data_set = [random.randint(0, (2**DATA_WIDTH)-1) for _ in range(CHAN_NUM)]
        inputs.append(list(data_set))
        
        # 計算排序結果
        sorted_set = sorted(data_set, reverse=(DIR == 1))
        goldens.append(sorted_set)

    with open(FILENAME, 'w') as f:
        f.write(f"// Input Data ({N_PAT} sets)\n")
        for data_set in inputs:
            for val in data_set:
                f.write(f"{val:04x}\n")
        
        f.write(f"\n// Golden Data ({N_PAT} sets)\n")
        for sorted_set in goldens:
            for val in sorted_set:
                f.write(f"{val:04x}\n")

if __name__ == "__main__":
    generate_data()
    print(f"Generated {FILENAME} with {N_PAT} test sets.")