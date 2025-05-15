#import "@preview/clean-dhbw:0.2.1": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#show: clean-dhbw.with(
  title: "Evaluierung von LLM‑basiertem QA",
  type-of-thesis: "Studienarbeit",
  authors: (
    (
      name: "Anton Seitz",
      student-id: "3626401",
      course: "INF22B",
      course-of-studies: "Informatik"
    ),
  ),
  at-university: true,
  city: "Stuttgart",
  abstract: "Diese Arbeit untersucht systematisch die Antwortqualität von #acrpl(\"LLM\")-basierten QA-Systemen. Aufbauend auf vorangegangenen Studien [@vaswani2017attention; @wolf2020transformers; @rajpurkar2016squad] wird ein Test‑Environment entwickelt, in dem ein definierter Textkorpus – u. a. judo­spezifische Quellen und Wikipedia‑Artikel – sowie variierte Fragestellungen verwendet werden. Die Bewertung erfolgt mithilfe quantitativer Metriken (Accuracy, Precision, Recall, F1‑Score, MRR, EM, SAS) und qualitativer Analysen. Das Ziel ist, die Grenzen heutiger Modelle aufzuzeigen und Optimierungspotential für praktische Anwendungen abzuleiten.",
  date: datetime.today(),
  language: "de",
  glossary: glossary,
  acronyms: acronyms,
  supervisor: (university: "Dr. Armin Roth"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Stuttgart",
  university-short: "DHBW"
)

= Kurzbeschreibung der Arbeit
Diese Studienarbeit befasst sich mit der Evaluierung von #acrpl("LLM")‑basiertem #acr("QA"). Im Fokus steht, wie gut moderne vortrainierte QA‑Modelle (z. B. *deepset/roberta-base-squad2*) Antworten liefern, wenn sie mit  
- vollem Kontext  
- semantisch reduziertem Kontext  
- internem Wissen nach LoRA‑Fine‑Tuning  
gefordert werden. Ein Test‑Environment erlaubt systematische Variation von Fragen, Metriken und Datenvolumen. Die Ergebnisse werden in Diagrammen visualisiert und diskutiert.

= Einleitung
== Motivation
Heutige #acrpl("LLM") wie GPT‑4 erreichen teils überraschend niedrige Korrektheitsraten im Fakten‑QA [@head-to-tail]. Diese Diskrepanz zwischen Erwartung und Realität motiviert die vorliegende Arbeit, die Zuverlässigkeit und Limitationen solcher Systeme zu untersuchen.

== Zielsetzungen
- Aufbau eines wiederholbaren QA‑Test‑Environments  
- Evaluierung mit vollständigem vs. reduziertem Kontext  
- LoRA‑basierte Feinabstimmung auf domänenspezifischen Text  
- Systematischer Vergleich der Performance  
- Ableitung von Empfehlungen für Praxis‑Deployments

= Grundlagen und Definitionen
== Transformer‑Architektur
Der Kern moderner #acrpl("LLM") ist der Transformer [@vaswani2017attention]. Ein Block besteht aus *Self-Attention* und Feed‑Forward‑Netzwerken, wodurch globale Token-Interaktionen ermöglicht werden.

=== Abbildung 1: Transformer‑Block
//![transformer-block](figs/transformer.png)

== Typen von QA-Systemen
- *Extractive QA:* Extrahiert Antwortspans aus einem vorgegebenen Kontext (z. B. SQuAD) [@rajpurkar2016squad].
- *Generative QA:* Generiert Antworten autonom, typischerweise mit autoregressiven LLMs [@wolf2020transformers].
- *Closed-Book QA:* Antworten allein aus gelerntem Wissen, ohne externen Kontext [@kwiatkowski2019nq].
- *Open-Domain QA:* Kombination aus Retriever (z. B. BM25, DPR) und Reader/Generator [@lewis2020rag].
- *Closed-Domain QA:* Spezialisierte Systeme für bestimmte Fachgebiete.
- *Cross-Lingual QA:* Frage und/oder Kontext in unterschiedlichen Sprachen [@reimers2019sentence].
- *Semantically Constrained QA:* Zusätzliche semantische Regeln, um Antworttypen einzuschränken.

== LoRA (Low-Rank Adaptation)
LoRA ergänzt Low-Rank-Matrizen in Attention-Projektionen und ermöglicht ressourcenschonendes Fine-Tuning [@hu2021lora].

= QA-Benchmarks
== SQuAD
Der Stanford Question Answering Dataset enthält über 100 000 Fragen zu Wikipedia-Artikeln [@rajpurkar2016squad]. SQuAD 2.0 ergänzt *unanswerable* Fragen [@rajpurkar2018squad2].

= Weitere Benchmarks
- Natural Questions [@kwiatkowski2019nq]  
- HotpotQA (Multi-Hop)  
- TyDiQA, XQuAD, MLQA (Multilingual) [@rajpurkar2019tydiqa]

= Metriken zur QA-Bewertung

In diesem Kapitel werden die zentralen Kennzahlen erläutert, mit denen wir die Qualität von Question‑Answering-Systemen messen. Jede Metrik beleuchtet einen spezifischen Aspekt: von der reinen Worttreue bis zur semantischen Tiefe der Antwort. Für unseren Use Case sind besonders robuste Metriken wie F1‑Score und Semantic Answer Similarity (SAS) entscheidend, da sie auch bei variierenden Formulierungen zuverlässige Bewertungen ermöglichen.

- *Accuracy (Genauigkeit):* Misst den Anteil aller korrekten Vorhersagen (True Positives und True Negatives) an der Gesamtzahl der Fälle. Sie beantwortet die Frage „Wie oft liegt das Modell richtig?“ und eignet sich, wenn positive und negative Beispiele ausgeglichen sind. Bei QA, wo oft nur positive Beispiele (Antworten) zählen, ist Accuracy nur eingeschränkt aussagekräftig.

  $ "Accuracy" = frac("TP" + "TN", "TP" + "TN" + "FP" + "FN") $

- *Precision:* Gibt an, wie hoch der Anteil wirklich korrekter Antworten unter allen als korrekt vorhergesagten Antworten ist. Präzision sagt aus, wie verlässlich die Treffer sind – ein hoher Precision‑Wert bedeutet wenige falsche Positiv‑Antworten.

  $ "Precision" = frac("TP", "TP" + "FP") $

- *Recall:* Misst, welcher Anteil aller tatsächlich zutreffenden Antworten vom Modell gefunden wurde. Recall zeigt die Vollständigkeit der Antworten – ein hoher Recall‑Wert bedeutet, dass wenige korrekte Antworten verpasst werden.

  $ "Recall" = frac("TP", "TP" + "FN") $

- *F1‑Score:* Das harmonische Mittel aus Precision und Recall. F1 vereint beide Perspektiven und ist besonders dann sinnvoll, wenn ein ausgewogenes Verhältnis von Genauigkeit und Vollständigkeit gefordert ist – typisch in QA, wo man sowohl richtige als auch vollständige Antworten benötigt.

  $ "F1" = frac(2 dot "Precision" dot "Recall", "Precision" + "Recall") $

- *Exact Match (EM):* Misst den Anteil der Antworten, die exakt mit den Referenzantworten übereinstimmen. EM ist besonders streng, da nur ganz genaue Textübereinstimmungen als korrekt gewertet werden. Für QA‑Systeme, die exakte Textspans ausgeben, bildet EM den härtesten Qualitätsmaßstab.

  $ "EM" = frac("Anzahl exakter Antworten", "Gesamtanzahl Fragen") $

- *Mean Reciprocal Rank (MRR):* Relevant für Pipeline‑Architekturen mit Ranking‑Komponente (Retriever). Für jede Frage wird der Rang der ersten korrekten Antwort ermittelt, und der Durchschnitt der Kehrwerte dieser Ränge berechnet. Ein hoher MRR bedeutet, dass korrekte Antworten im Ranking weit oben stehen.

  $ "MRR" = frac(1, |Q|) sum_{i=1}^{|Q|} frac(1, "rank"_i) $

- *Semantic Answer Similarity (SAS):* Ein lernbarer semantischer Metrik‑Score im Bereich $[0,1]$. SAS bewertet, wie inhaltlich ähnlich eine generierte Antwort zur Gold‑Antwort ist, selbst wenn sie anders formuliert ist. Diese Metrik ergänzt string‑basierte Maße und ist in unserem Use Case wichtig, weil sie semantisch korrekte Paraphrasen erkennt.

---

Diese Metriken kombiniert erlauben eine umfassende Beurteilung:  
- *Accuracy, Precision, Recall, F1* bewerten Token‑ und Span‑Ebene direkt.  
- *EM* prüft wortwörtliche Korrektheit.  
- *MRR* bewertet die Qualität des Retrieval-Teils.  
- *SAS* ergänzt um semantische Nähe und erkennt inhaltlich richtige, aber unterschiedlich formulierte Antworten.

Für unseren Use Case sind insbesondere F1 und SAS zentral, da sie sowohl Teil‑ als auch semantische Übereinstimmung messen und somit robust gegen kleine Formulierungsunterschiede sind.


= Retrieval-Augmented Generation (RAG)
RAG verbindet Retriever und Generator: Ein Retriever liefert relevante Passagen, ein Generator (seq2seq) generiert die Antwort [@lewis2020rag].

= Umsetzung eines QA-Testframeworks
Nutze Python und Jupyter-Notebooks. Infrastrukturempfehlungen:
- Bibliotheken: `transformers`, `datasets`, `peft`, `evaluate`  
- Logging: Weights & Biases  
- Versionierung: Git + `requirements.txt`  
- Zufallskeim-Festlegung: `random.seed()`, `numpy.random.seed()`  
- Notebook-Struktur: Datenaufbereitung, Chunking, Modellinferenz, Evaluation, Visualisierung

= Realisierung
Weitere Details und Codebeispiele befinden sich im Anhang (Notebook-Zellen).

= Evaluierung
== Performance-Vergleich
Die drei Pipeline-Varianten liefern unterschiedliche Accuracy:
- FullContext: 85.2 %
- ReducedContext: 78.6 %
- FineTuned: 92.3 %

== Diskussion
- Kontextreduktion: −7 % Accuracy, +40 % Speed  
- LoRA-Fine-Tuning: +7 % Accuracy gegenüber FullContext

= Zusammenfassung und Ausblick
== Schlussfolgerungen
Hybrid aus semantischem Retrieval + LoRA-Fine-Tuning ist effizient und genau.

== Empfehlungen
- Produktion: Retrieval + LoRA  
- Forschung: Generative Multi-Hop QA, semantische Constraints

= Anhang
- Vollständige Code-Listings im Notebook
- Glossar & Abkürzungen

#pagebreak()
= Bibliographie
#bibliography("zotero.bib", style: "american-psychological-association", title: none)