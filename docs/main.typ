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
  abstract: "Führende Large Language Models (LLMs) werden im Zuge des aktuellen Hypes häufig als Alleskönner dargestellt. Aus vorangegangenen Studien ist jedoch ersichtlich, dass diese Modelle oftmals ein mangelhaftes Faktenwissen aufweisen und selbst bei bekannten Informationen natürlichsprachliche Fragen fehlerhaft beantworten. Sogar das beste getestete Modell, GPT-4, erreichte hier nur 40,3% korrekte Antworten. Diese Diskrepanz zwischen den Erwartungen und der tatsächlichen Leistungsfähigkeit bildet die Motivation für diese Arbeit. Das Ziel ist, die Grenzen der Leistungsfähigkeit von LLM systematisch zu erforschen.
",
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

== Künstliche Intelligenz  
Künstliche Intelligenz (KI) ist der Oberbegriff für Technologien, die Computern ermöglichen, menschliche Denkprozesse wie Lernen, Schlussfolgern und Entscheidungsfindung zu simulieren @IBM2024_WhatIsAI. Moderne KI setzt vor allem auf Machine Learning:  
- Computer erhalten eine große Menge von Beispieldaten (z. B. frühere Käufe),  
- sie erkennen darin Muster und Zusammenhänge (z. B. welche Produkte häufig gemeinsam gekauft werden) und  
- passen ihre internen Parameter so an, dass sie Vorhersagen für neue Daten treffen können @MITSloan2020_MLExplained.  
Dieses „Musterlernen“ erlaubt es, Konsumenten individuelle Produktempfehlungen auszugeben oder Preise dynamisch anzupassen, was nachweislich die Conversion-Rate erhöht und das Kundenerlebnis verbessert @HBR2023_CX.
#figure(
  image("assets/ai-graph.svg"),
  caption: [@McKinsey2024_StateOfAI Immer mehr Unternehmen benutzen KI um einen oder mehrere Geschäftsprozesse zu automatisieren. Seit der einfachen Verfügbarkeit von generativer KI, wurde diese auch rapide adaptiert. Im @sec:genai wird diese Technologie noch genauer beleuchtet]
)<fig:mck-ai>
== Generative AI  
<sec:genai>
#grid(
  columns: (2fr, 1.5fr),
  gutter: 10pt,
  [
Generative AI bezeichnet KI-Ansätze, die neue Inhalte wie Texte, Bilder oder Videos erzeugen können @McKinsey2024_GenerativeAI. Ausschlaggebend war das Transformer-Modell von Vaswani et al. (2017). Dieses Forscherteam bei Google Brain legte mit dem Paper _Attention Is All You Need_ den Grundstein für die heute gängigen Sprachmodelle wie ChatGPT. Sie setzten vollständig auf Self-Attention – ein Verfahren, bei dem jedes Element (z. B. ein Wort) alle anderen im Satz „gewichtet“, um die für den Kontext wichtigsten Informationen herauszufiltern und zu kombinieren @vaswani2017attention.  
Unternehmen nutzen Generative AI z.B. um in Echtzeit Produktbilder oder Werbeclips zu erzeugen, die exakt zu Nutzerpräferenzen passen. So kann z. B. eine Online-Modeplattform  automatisch Outfits in verschiedenen Stilen generieren @McKinsey2024_StateOfAI.
  ],
  figure(
  image("assets/ai-all.png"),
  caption: [Einordnung von GenAI @sas_genai_landscape2024]
)
)


=== Transformer‑Architektur  
Der Transformer ist die Standardarchitektur heutiger LLMs [@vaswani2017attention]. Er besteht aus gestapelten Encoder‑ und/oder Decoder‑Blöcken mit Self‑Attention und Feed‑Forward-Netzwerken, erlaubt paralleles Training und erfasst langreichweitige Abhängigkeiten.

$ "Attention"(Q, K, V) = "softmax"(frac(Q K^T, sqrt(d_k))) V $

$ "MultiHead"(Q, K, V) = "concat"("head"_1, dots, "head"_h) W^O $

$ "head"_i = "Attention"(Q W_i^Q, K W_i^K, V W_i^V) $

=== Trainingsverfahren  
LLMs durchlaufen zwei Phasen:
- *Pretraining*  
  • Masked Language Modeling (BERT) [@devlin2019bert]  
  • Autoregressive Next-Token-Prediction (GPT) [@wolf2020transformers]  
- *Fine‑Tuning*  
  Spezialisierung auf Aufgaben oder Domänen. Moderne Systeme wie GPT-4 nutzen zusätzlich *Reinforcement Learning from Human Feedback* (RLHF) [@hu2021lora].

= Question‑Answering‑Systeme

== Was sind Question‑Answering‑Systeme?  
Question‑Answering‑Systeme (QA‑Systeme) sind Anwendungen, die automatisch auf natürlichsprachliche Fragen Text­antworten liefern. Sie kombinieren Information Retrieval (z. B. Dokumentensuche) und Natural Language Processing (z. B. Named Entity Recognition, Parsing), um in einem Korpus oder internem Modellwissen die richtige Antwort zu finden.

== Arten von Wissen  
Knowledge lässt sich in verschiedene Kategorien unterteilen, die für QA‑Systeme relevant sind. Basierend auf dem Dokument *Types and qualities of knowledge* lassen sich folgende Typen unterscheiden:

- *Factual Knowledge* (auch *Conceptual knowledge*):  
  Dieses Wissen umfasst statische Fakten und Konzepte, z. B. „Berlin ist die Hauptstadt Deutschlands“. QA‑Systeme greifen hier häufig auf explizite Datenbanken oder Textpassagen zurück @knowledge.

- *Procedural Knowledge*:  
  Beschreibt Abläufe und Handlungsanweisungen, z. B. Kochrezepte oder Montageanleitungen. QA im prozeduralen Bereich muss oft Schritt‑für‑Schritt antworten.

- *Metacognitive Knowledge*:  
  Umfasst Wissen über die eigenen Wissensgrenzen und -prozesse, etwa „Ich weiß, dass ich etwas nicht weiß“. Für QA weniger direkt relevant, kann aber bei Unsicherheitserkennung helfen.

- *Semantic Knowledge*:  
  Erklärt Bedeutungen und Zusammenhänge zwischen Konzepten, z. B. Taxonomien in Ontologien. Semantisch angereicherte QA‑Systeme nutzen dieses Wissen, um Antworten präziser zu formulieren.

- *Contextual Knowledge*:  
  Form von Wissen, das an einen bestimmten Kontext gebunden ist (z. B. aktuelle Nachrichten, persönliche Vorlieben). Open‑Domain‑QA‑Systeme müssen dynamisch darauf zugreifen.

== Fokus auf Faktenwissen  
Wir konzentrieren uns in dieser Arbeit auf *Factual Knowledge* („Conceptual knowledge“), da aktuelle LLMs hier erhebliche Defizite zeigen. Studien belegen, dass selbst GPT‑4 im Fakten‑QA nur ca. 40,3 % korrekte Antworten liefert, obwohl diese Informationen während Pre‑Training oft mehrfach auftauchen (@head-to-tail).

=== Typen von QA‑Systemen
/*
- *Extractive QA*  
  Das System erhält eine Frage und einen Kontexttext und markiert den besten Antwortspan im Text. Die Antworten stammen wortwörtlich aus dem Dokument, zum Beispiel im SQuAD–Datensatz [@rajpurkar2016squad; @rajpurkar2018squad2]. Reader-Modelle basieren häufig auf BERT-ähnlichen Encodern, die den relevanten Abschnitt im Text „ziehen“ [@devlin2019bert; @wolf2020transformers].
*/
- *Extractive QA*: 
  
  Bei dieser Methode erhält das Modell eine Frage und einen zusammenhängenden Textabschnitt (Kontext). Es identifiziert dann genau den oder die Wortgruppen (Spans), die die beste Antwort enthalten. Zum Beispiel sucht ein System in einem Wikipedia-Artikel nach der Textstelle, die erklärt, wofür Einstein den Nobelpreis erhielt @rajpurkar2016squad. Extractive QA ist besonders zuverlässig, da die Antwort wortwörtlich aus dem vorgegebenen Text stammt und so keine inhaltliche Erfindung (Halluzination) erfolgt.
  - *Arbeitsweise:* Das Modell nutzt einen Token-basierten Klassifikator, um Start- und End-Position der Antwort im Kontext vorherzusagen.
  - *Vorteile:* Hohe Präzision und Nachvollziehbarkeit; geringe Gefahr von Halluzinationen.
  - *Nachteile:* Antworten müssen wortwörtlich im Kontext stehen; keine freie Formulierung.

- *Generative QA*  
  Hier erzeugt das Modell die Antwort eigenständig aus Frage und Kontext, statt sie wortwörtlich zu übernehmen. Moderne LLMs wie GPT‑Modelle erstellen frei formulierte Fließtext-Antworten [@wolf2020transformers].

- *Closed‑Book QA*  
  Das Modell nutzt nur im Pretraining erworbenes Wissen, ohne zusätzliche Kontext-Eingabe. Typisches Beispiel sind GPT‑basierten Chatbots, die über intern gelernten Wissensspeicher verfügen [@wolf2020transformers].

- *Open‑Domain QA*  
  Systeme greifen auf ein großes Wissensreservoir (z.B. Wikipedia) zu. Ein Retriever identifiziert relevante Dokumente, die ein Reader oder Generator anschließend für die Antwort nutzt (Retrieval-Augmented Generation) [@lewis2020rag].

- *Closed‑Domain QA*  
  Beschränkt auf ein Fachgebiet (z.B. Medizin). Hier kann das System auf Domänen‑Ontologien oder spezialisierte Korpora zugreifen, um präzisere Antworten zu liefern [@kwiatkowski2019nq].

- *Cross‑Lingual QA*  
  Frage und/oder Kontext können in unterschiedlichen Sprachen sein. Benchmarks wie TyDiQA oder MLQA prüfen die Fähigkeit, in mehreren Sprachen zu antworten [@rajpurkar2019tydiqa].

- *Semantically Constrained QA*  
  Nutzt zusätzliche semantische Regeln oder Ontologien, um nur Antworten eines bestimmten Typs zuzulassen. Diese Form steigert die Präzision in spezialisierten Anwendungen [@reimers2019sentence].

== Aktuelle LLMs: Architektur und Training


== Fine‑Tuning

Fine‑Tuning bezeichnet das Anpassen eines vortrainierten #acr("LLM") an eine konkrete Aufgabe durch weiteres Training mit gelabelten Beispielen. Dabei wird die Performance des Modells gezielt auf domänenspezifische Eingaben optimiert.

Das Ziel ist, das bereits vorhandene Sprachverständnis des Modells durch zusätzliche, oft kleinere Datenmengen so zu verfeinern, dass es auf die Zielanwendung zugeschnittene Antworten liefern kann.

=== Full‑Parameter‑Fine‑Tuning

Beim klassischen Fine‑Tuning werden alle Modellgewichte $ bold(W) in RR^(d times k) $ aktualisiert. Die Gewichte werden dabei durch Minimierung einer passenden Verlustfunktion wie Kreuzentropie angepasst:

$ min_(bold(W)) sum_(i=1)^N cal(L)(f(bold(x)_i; bold(W)), y_i) $

- Vorteile:
  - Hohe Ausdrucksstärke durch vollständige Anpassung aller Schichten.
- Nachteile:
  - Hoher Speicherverbrauch (alle Parameter müssen im Training gehalten werden)
  - Geringe Wiederverwendbarkeit des Modells (Task-spezifisch)
  - Lange Trainingsdauer und hoher Rechenbedarf

=== LoRA‑Fine‑Tuning

*Low-Rank Adaptation (LoRA)* ist eine Methode aus dem Bereich *Parameter Efficient Fine-Tuning* (#acr("PEFT")), bei der nur wenige zusätzliche Gewichte trainiert werden.

Anstatt $bold(W)$ direkt zu aktualisieren, wird eine Veränderung $ Delta bold(W) $ als Produkt zweier kleiner Matrizen eingeführt:

$ bold(W) = bold(W)_0 + Delta bold(W) = bold(W)_0 + bold(A) dot bold(B) $

Dabei sind:
- $bold(A) in RR^(d times r)$
- $bold(B) in RR^(r times k)$
- $r "ll" min(d, k)$

Das bedeutet, anstelle von $d dot k$ Parametern werden nur $(d + k) dot r$ Parameter trainiert:

$ frac((d + k) dot r, d dot k) "ll" 1 $

Beispiel: Für $d = k = 768$, $r = 8$ ergibt sich eine Reduktion auf nur ca. 2% der ursprünglichen Parameteranzahl.

- Vorteile:
  - Geringer Speicherbedarf
  - Task-spezifische Adapter lassen sich effizient laden
  - Vortrainiertes Modell bleibt unangetastet
- Nachteile:
  - Potenziell geringere Performanz bei zu kleinem $r$
  - Mehr Aufwand beim Deployment verschiedener Adapter

=== Visualisierungen (empfohlen)

- *Abbildung 1:* Full‑Fine‑Tuning: gesamte Gewichtsmatrix wird angepasst
- *Abbildung 2:* LoRA: nur low‑rank Matrizen $bold(A)$ und $bold(B)$ werden trainiert
- *Abbildung 3:* Vergleich der trainierbaren Parameter (LoRA vs. Full-Tuning) in Abhängigkeit von $r$

=== Mathematischer Vergleich

| Methode           | Trainierbare Parameter             | Speicherbedarf         |
|-------------------|------------------------------------|-------------------------|
| Full‑Tuning       | $d dot k$                        | $O(d dot k)$           |
| LoRA (rank $r$)   | $(d + k) dot r$                  | $O((d + k) dot r)$     |


= QA-Benchmarks

== SQuAD
Der Stanford Question Answering Dataset enthält über 100000 Fragen zu Wikipedia-Artikeln @rajpurkar2016squad.
SQuAD 2.0 ergänzt unanswerable Fragen @rajpurkar2018squad2.

- Exact Match EM berechnet den Anteil exakter Übereinstimmungen
- F1-Score misst den Token-Overlap zwischen prognostiziertem und Gold-Span

$ "F1" = 2 |P ∩ G| / (|P| + |G|) $

== Weitere Benchmarks
- Natural Questions dokumentiert reale Suchanfragen und ist offen für Closed-Book QA @kwiatkowski2019nq
- HotpotQA fordert Multi-Hop-Reasoning
- TyDiQA, XQuAD und MLQA testen multilinguale Fähigkeiten @rajpurkar2019tydiqa

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