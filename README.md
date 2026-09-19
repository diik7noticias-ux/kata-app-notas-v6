# Template Flutter Base

Template base para apps Flutter geradas pelo KATA.

## Placeholders substituidos pelo agente

- `notas_v6`      nome tecnico em snake_case (ex: lista_compras)
- `Notas V6`   nome visivel (ex: Lista de Compras)
- `org.kata.notasv6`        package id (ex: org.kata.listacompras)
- `2026`          ano atual

## Estrutura

    lib/
      main.dart             entry point + roteamento
      theme.dart            cores + tema global
      screens/              ecras da app
      widgets/              componentes reutilizaveis
      services/             chamadas HTTP, BD, etc.
      models/               classes de dados

O agente substitui normalmente `lib/screens/home_screen.dart`
e adiciona ficheiros novos em `screens/`, `widgets/`, etc.
