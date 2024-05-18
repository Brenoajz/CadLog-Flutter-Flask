from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json

app = Flask(__name__)
CORS(app)  # Habilita CORS para todas as rotas

# Caminho para o arquivo dados.json
caminho_arquivo = os.path.join(os.path.dirname(__file__), 'dados.json')

def adicionar_usuario(cpf, nome, senha):
    # Verificar se o arquivo já existe
    if os.path.exists(caminho_arquivo):
        # Abrir o arquivo no modo de leitura
        with open(caminho_arquivo, 'r') as arquivo:
            # Carregar os dados existentes
            dados = json.load(arquivo)
    else:
        dados = []

    # Adicionar novo usuário aos dados
    dados.append({'cpf': cpf, 'nome': nome, 'senha': senha})

    # Abrir o arquivo no modo de escrita e salvar os dados em formato JSON
    with open(caminho_arquivo, 'w') as arquivo:
        json.dump(dados, arquivo)

def adicionar_detalhes_evento(cpf, descricao):
    # Verificar se o arquivo já existe
    if os.path.exists(caminho_arquivo):
        # Abrir o arquivo no modo de leitura
        with open(caminho_arquivo, 'r') as arquivo:
            # Carregar os dados existentes
            dados = json.load(arquivo)
    else:
        dados = []

    # Adicionar novos detalhes de evento aos dados
    dados.append({'cpf': cpf, 'descricao': descricao})

    # Abrir o arquivo no modo de escrita e salvar os dados em formato JSON
    with open(caminho_arquivo, 'w') as arquivo:
        json.dump(dados, arquivo)

def _verificar_existencia_cpf(cpf):
    # Verificar se o arquivo existe
    if os.path.exists(caminho_arquivo):
        # Abrir o arquivo no modo de leitura
        with open(caminho_arquivo, 'r') as arquivo:
            # Carregar os dados existentes
            dados = json.load(arquivo)
            # Verificar se o CPF já existe nos dados
            for usuario in dados:
                if usuario['cpf'] == cpf:
                    return True
    return False

def _verificar_senha(cpf, senha):
    # Abrir o arquivo e verificar se o CPF e a senha correspondem
    if os.path.exists(caminho_arquivo):
        with open(caminho_arquivo, 'r') as arquivo:
            dados = json.load(arquivo)
            for usuario in dados:
                if usuario['cpf'] == cpf and usuario['senha'] == senha:
                    return True
    return False

@app.route('/cadastrar', methods=['POST'])
def cadastrar():
    data = request.form
    cpf = data['cpf']
    nome = data['nome']
    senha = data['senha']

    # Verificar se o CPF já está cadastrado
    if _verificar_existencia_cpf(cpf):
        return jsonify({'message': 'CPF já cadastrado.'}), 400

    # Adicionar usuário ao arquivo dados.json
    adicionar_usuario(cpf, nome, senha)

    return jsonify({'message': 'Cadastro realizado com sucesso.', 'status_code': 200}), 200

@app.route('/verificar_cpf', methods=['GET'])
def verificar_cpf():
    cpf = request.args.get('cpf')
    if _verificar_existencia_cpf(cpf):
        return jsonify({'exists': True}), 200
    else:
        return jsonify({'exists': False}), 200

@app.route('/login', methods=['POST'])
def login():
    data = request.form
    cpf = data['cpf']
    senha = data['senha']

    # Verificar se o CPF existe e se a senha corresponde
    if _verificar_existencia_cpf(cpf):
        # Verificar a senha
        if _verificar_senha(cpf, senha):
            return jsonify({'authenticated': True}), 200
    return jsonify({'authenticated': False}), 401

@app.route('/enviar_detalhes', methods=['POST'])
def enviar_detalhes():
    data = request.form
    cpf = data['cpf']
    descricao = data['descricao']

    # Adicionar detalhes do evento ao arquivo dados.json
    adicionar_detalhes_evento(cpf, descricao)

    return jsonify({'message': 'Detalhes do evento enviados com sucesso.', 'status_code': 200}), 200

if __name__ == '__main__':
    app.run(debug=True)
