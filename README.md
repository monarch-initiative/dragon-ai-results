[![DOI](https://zenodo.org/badge/13996/monarch-initiative/dragon-ai-results.svg)](https://zenodo.org/badge/latestdoi/13996/monarch-initiative/dragon-ai-results)

This repo contains analysis for the DRAGON-AI paper: https://arxiv.org/abs/2312.10904

## Reproducing predictions

Source ontologies are in [downloads](downloads)

## Results Analysis

The main input file for the definition analysis is here: https://github.com/monarch-initiative/dragon-ai-results/blob/main/definitions-sheets/eval.csv

- [notebooks/CollectDefinitionEvaluations.ipynb](notebooks/CollectDefinitionEvaluations.ipynb)
    - aggregates definition evaluations from google drive
    - joins evaluation plus metadata about how the definition was generated
- [notebooks/DefinitionEvaluationAnalysis.ipynb](notebooks/DefinitionEvaluationAnalysis.ipynb) 
    - analyzes definition evaluations
- [notebooks/CollectRelationships.ipynb](notebooks/CollectRelationships.ipynb)
    - aggregates individual files from executing DRAGON on relationship task
    - uses ontology path traversal to classify outputs into TP/FP/FN
- [notebooks/RelationshipsAnalysis.ipynb](notebooks/RelationshipsAnalysis.ipynb)
    - summarize relationship task

The source google sheet for the manual relationship eval is [here](https://docs.google.com/spreadsheets/d/1YgQgEiSgO5ru8yBKb1tlwmCo-S566no0YHhrFLwRR0E/edit?gid=687340154#gid=687340154)

