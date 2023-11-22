Analysis for the paper https://docs.google.com/document/d/1bevI2vPuoe75raL-FNyOFkPWz5g3IyAnNGdzlO4cf4Y/edit

The main input file for the definition analysis is here: https://github.com/monarch-initiative/gpt-ontology-completion-analysis/blob/main/definitions-sheets/eval.csv

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

