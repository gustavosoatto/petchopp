# Backend do Aplicativo NFC (Petchopp)

Este é o backend para o aplicativo de leitura NFC, construído com Laravel, utilizando PostgreSQL como banco de dados e orquestrado com Docker. Ele fornece uma API para verificar tags NFC cadastradas.

## Requisitos

*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) (ou Docker Engine) instalado e em execução.

## Configuração do Projeto

1.  Navegue até o diretório `backend` do projeto:
    ```bash
    cd C:\Users\Vitor Almeida\Desktop\git\e1-rest-docker-petchopp-main\backend
    ```

## Configuração do Ambiente Docker

O projeto utiliza Docker Compose para gerenciar os serviços da aplicação (PHP-FPM), o servidor web (Nginx) e o banco de dados (PostgreSQL).

1.  **Inicie os contêineres Docker:**
    Este comando irá construir as imagens (se necessário) e iniciar todos os serviços em segundo plano.
    ```bash
    docker-compose up -d --build
    ```
    Aguarde alguns minutos para que todos os serviços sejam iniciados e as imagens construídas.

## Configuração do Laravel

1.  **Crie o arquivo de ambiente (`.env`):**
    O Laravel utiliza um arquivo `.env` para configurações específicas do ambiente. Copie o arquivo de exemplo e configure-o.
    ```bash
    cp .env.example .env
    ```

2.  **Edite o arquivo `.env`:**
    Abra o arquivo `.env` recém-criado e certifique-se de que as configurações do banco de dados e do ambiente estejam corretas, conforme abaixo:

    ```dotenv
    APP_ENV=local
    APP_KEY=
    DB_CONNECTION=pgsql
    DB_HOST=db
    DB_PORT=5432
    DB_DATABASE=petchopp
    DB_USERNAME=user
    DB_PASSWORD=password
    ```

3.  **Instale as dependências do Composer:**
    Execute o Composer dentro do contêiner da aplicação para instalar todas as dependências do PHP.
    ```bash
    docker-compose exec app composer install
    ```

4.  **Gere a chave da aplicação:**
    O Laravel requer uma chave de aplicação para segurança.
    ```bash
    docker-compose exec app php artisan key:generate
    ```

5.  **Execute as migrações do banco de dados:**
    Isso criará as tabelas necessárias no banco de dados PostgreSQL, incluindo a tabela `nfc_cards`.
    ```bash
    docker-compose exec app php artisan migrate
    ```

## Estrutura da API (Verificação NFC)

O backend expõe um endpoint para verificar tags NFC:

*   **Endpoint:** `POST /api/verify-nfc`
*   **URL Completa:** `http://localhost:8000/api/verify-nfc`
*   **Parâmetros (JSON Body):**
    *   `nfc_tag`: `string` (O identificador único da tag NFC a ser verificada).

*   **Respostas:**
    *   **Sucesso (200 OK):**
        ```json
        {
            "status": "success",
            "message": "Cartão NFC encontrado e verificado.",
            "card_details": {
                "id": 1,
                "nfc_tag": "YOUR_NFC_TAG_HERE",
                "details": "Detalhes do Cartão",
                "created_at": "2023-01-01T12:00:00.000000Z",
                "updated_at": "2023-01-01T12:00:00.000000Z"
            }
        }
        ```
    *   **Erro (404 Not Found):**
        ```json
        {
            "status": "error",
            "message": "Cartão NFC não encontrado ou não registrado."
        }
        ```
    *   **Erro de Validação (422 Unprocessable Entity):**
        ```json
        {
            "message": "The nfc tag field is required.",
            "errors": {
                "nfc_tag": [
                    "The nfc tag field is required."
                ]
            }
        }
        ```

## Como Testar

1.  **Adicione dados de teste à tabela `nfc_cards`:**
    Você pode usar o Tinker do Laravel para adicionar um registro de teste.
    ```bash
    docker-compose exec app php artisan tinker
    ```
    No prompt do Tinker, execute:
    ```php
    >>> App\Models\NfcCard::create(['nfc_tag' => 'TAG_EXEMPLO_123', 'details' => 'Cartão de Acesso Principal']);
    ```
    Pressione `Ctrl+C` para sair do Tinker.

2.  **Teste o endpoint da API usando `curl`:**
    *   **Para uma tag existente:**
        ```bash
        curl -X POST http://localhost:8000/api/verify-nfc \
             -H "Content-Type: application/json" \
             -d '{"nfc_tag": "TAG_EXEMPLO_123"}'
        ```
    *   **Para uma tag não existente:**
        ```bash
        curl -X POST http://localhost:8000/api/verify-nfc \
             -H "Content-Type: application/json" \
             -d '{"nfc_tag": "TAG_INEXISTENTE_456"}'
        ```

## Parar o Ambiente Docker

Para parar e remover os contêineres, redes e volumes criados pelo Docker Compose:
```bash
docker-compose down
```