import pandas as pd

data = r'C:\Users\ASUS\OneDrive\SQL\Online Retail\online-retail-v2\Code\Online Retail.xlsx'
df = pd.read_excel(data)
#Kiểm tra data type của các cột
for column in df.columns:
    print(f"{column}: {df[column].dtype}")
# Kiểm tra kiểu dữ liệu của biến data
print(type(df))
# Kiểm tra giá trị null của bộ data
print(df.isnull().sum())

