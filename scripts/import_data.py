import sqlite3
import pandas as pd
import os

# Caminho dos CSV's 
caminho = 'data/'

# Nome do banco
conn = sqlite3.connect('olist.db')

# Arquivos

arquivos = {
    'orders': 'olist_orders_dataset.csv',
    'order_items': 'olist_order_items_dataset.csv',
    'order_payments': 'olist_order_payments_dataset.csv',
    'order_reviews': 'olist_order_reviews_dataset.csv',
    'customers': 'olist_customers_dataset.csv',
    'products': 'olist_products_dataset.csv',
    'sellers': 'olist_sellers_dataset.csv',
    'product_category': 'product_category_name_translation.csv',
}

for tabela, arquivo in arquivos.items():
    caminho_completo = os.path.join(caminho, arquivo)
    df = pd.read_csv(caminho_completo)
    df.to_sql(tabela, conn, if_exists='replace', index=False)
    print(f'{tabela} importada - {len(df)} linhas')

conn.close()
print('\nBanco olist.db criado com sucesso!')
