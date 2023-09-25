OBO = http://purl.obolibrary.org/obo
#RUN = poetry run
RUN =
CURATE = $(RUN) curategpt

DB_PATH = db

ONTS = cl uberon obi go envo hp mp mondo po to oba agro fbbt nbo chebi vo peco
TRACKERS = cl uberon obi  envo hp mondo go


all: index_all_ont

## -- Ontology Indexing --


index_all_ont: $(patsubst %,ont-%,$(ONTS))
index_all_issues: $(patsubst %,load-github-%,$(ONTS))

ont-%:
	$(CURATE) ontology index --index-fields label,definition,relationships -p $(DB_PATH) -c ont_$* -m openai: sqlite:obo:$*


## -- GitHub issues --

# TODO: patternize

load-github-uberon:
	$(CURATE) -v view index  -p $(DB_PATH) -c gh_uberon -m openai:  --view github --init-with "{repo: obophenotype/uberon}"

load-github-hp:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_hp -m openai:  --view github --init-with "{repo: obophenotype/human-phenotype-ontology}"

load-github-mondo:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_mondo -m openai:  --view github --init-with "{repo: monarch-initiative/mondo}"

load-github-go:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_go -m openai:  --view github --init-with "{repo: geneontology/go-ontology}"

load-github-cl:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_cl -m openai:  --view github --init-with "{repo: obophenotype/cell-ontology}"

load-github-envo:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_envo -m openai:  --view github --init-with "{repo: EnvironmentOntology/envo}"

load-github-foodon:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_foodon -m openai:  --view github --init-with "{repo: FoodOntology/foodon}"

load-github-obi:
	$(CURATE) -v view index -p $(DB_PATH) -c gh_obi -m openai:  --view github --init-with "{repo: obi-ontology/obi}"

# load docs

load-docs-cl:
	$(CURATE) -v view index -p $(DB_PATH) -c devdocs_cl -m openai:  --view filesystem --init-with "{root_directory: ../cell-ontology/docs, glob: '**/*.md'}"

# all collections

list:
	$(CURATE) collections list -p $(DB_PATH)


# generating test sets;
# these are drawn from most recent results

inputs/%-testing-ids-2023.txt:
	runoak -i sqlite:obo:$* query -q "SELECT subject FROM statements WHERE predicate in ('dcterms:date', 'dce:date', 'IAO:0006012', 'oio:creation_date') AND value LIKE '2023%' AND LOWER(subject) like '$*:%'" > $@.tmp && mv $@.tmp $@ && wc $@

inputs/envo-testing-ids-2023.txt: historic/envo-new-terms.tsv
	cp $< $@

inputs/obi-testing-ids-2023.txt: historic/obi-new-terms.tsv
	cp $< $@

inputs/go-regulation.txt:
	runoak -i sqlite:obo:go descendants -p i "regulation of biological process" > $@

inputs/go-enzyme.txt:
	runoak -i sqlite:obo:go descendants -p i "catalytic activity"  -o $@

inputs/cl-immune.txt:
	runoak -i sqlite:obo:cl descendants -p i "immune cell"  -o $@

inputs/split-%: inputs/%-testing-ids-2023.txt
	$(CURATE) -v collections split -m openai: -c ont_$* -F label,definition,relationships -o db --test-id-file $< && touch $@

inputs/split-go-enzyme: inputs/go-enzyme.txt
	$(CURATE) -v collections split --num-testing 100 -m openai: -c ont_go --derived-collection-base ont_go_enzyme -F label,definition,relationships -o db --test-id-file $< && touch $@

inputs/split-cl-immune: inputs/cl-immune.txt
	$(CURATE) -v collections split --num-testing 100 -m openai: -c ont_cl --derived-collection-base ont_cl_immune -F label,definition,relationships -o db --test-id-file $< && touch $@


historic/%-current.obo:
	curl -L -s $(OBO)/$*.obo > $@

historic/envo-past-2022.obo:
	curl -L -s $(OBO)/envo/releases/2021-05-14/envo.obo > $@

historic/obi-past-2022.obo:
	curl -L -s $(OBO)/obi/2022-12-14/obi.obo > $@

historic/oba-past-2022.obo:
	curl -L -s $(OBO)/oba/releases/2022-11-26/oba.obo > $@

historic/%-new-terms.tsv:
	runoak -i simpleobo:historic/$*-past-2022.obo diff -X simpleobo:historic/$*-current.obo --simple -O csv --change-type ClassCreation -o $@.tmp && cut -f3 $@.tmp | grep -i $*: > $@ && wc $@


# generate configs

#conf/eval-conf-%.yaml: conf/eval-conf-template.yaml.jinja2
#	./util/gen-conf.pl $* $< > $@

# note: uberon handled differentlyas it has <50
conf/eval-conf-main.yaml:
	$(CURATE) evaluation-config --collections ont_envo,ont_obi,ont_go,ont_cl,ont_mondo,ont_foodon,ont_oba,ont_hp,ont_mp --background false --fields-to-predict label,definition,relationships > $@

conf/eval-conf-definition.yaml:
	$(CURATE) evaluation-config --collections ont_envo,ont_obi,ont_go,ont_cl,ont_mondo,ont_foodon,ont_oba,ont_hp,ont_mp --background false --fields-to-predict definition > $@

# only a subset
conf/eval-conf-logical-definition.yaml:
	$(CURATE) evaluation-config --collections ont_cl,ont_go,ont_mondo,ont_oba,ont_hp,ont_mp --background false --fields-to-predict logical_definition > $@

conf/eval-conf-main-model-%.yaml:
	$(CURATE) evaluation-config --models $* --collections ont_envo,ont_obi,ont_go,ont_cl,ont_mondo,ont_oba,ont_hp --background false --fields-to-predict label,definition,relationships > $@

results/run-%: conf/eval-conf-%.yaml
	curategpt  -v evaluate --num-testing 50 -W results $< > $@


results/cl-defs-direct.tsv:
	$(CURATE) multiprompt -m gpt-4 --system "your role is to provide concise textual definitions in the style of the cell ontology for the cell types I provide" --prompt "{subject_label}"  inputs/cl-testing-ids-2023.txt > $@
