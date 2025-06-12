#import "@preview/clean-dhbw:0.2.1": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary
#import "@preview/dashy-todo:0.0.3": todo
#import "@preview/ctheorems:1.1.3": *

// ctheorems
#let theorem = thmbox("theorem", "Theorem", fill: rgb("#f3f3f3"))
#let corollary = thmplain(
  "corollary",
  "Korollar",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox(
  width: 120%,
  "definition",
  "Definition",
  inset: (x: 1.2em, top: 1em, bottom: 1em),
  fill: rgb("#f8f8f8"),

)
#let example = thmbox("example", "Beispiel", fill: rgb("#f8f8f8")).with(numbering: none)
#let proof = thmproof("proof", "Beweis")


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
#set text(size: 12pt)

= Kurzbeschreibung der Arbeit
In dieser Studienarbeit wird die Leistungsfähigkeit moderner Large Language Models (LLMs) im Bereich des Question Answering (QA) systematisch untersucht. Ausgangspunkt ist die Erkenntnis, dass selbst hochentwickelte Modelle wie GPT-4 nur rund 40 % der Fragen korrekt beantworten, obwohl ihnen häufig universelle Problemlöserfähigkeiten zugeschrieben werden @head-to-tail. Zunächst wird ein thematisch geeigneter Textkorpus ausgewählt und für die spätere Evaluierung aufbereitet. Darauf aufbauend werden Testfragen formuliert und Referenzantworten erstellt, um eine belastbare Vergleichsbasis zu schaffen.

Anschließend wird ein ausgewähltes LLM in einer speziell eingerichteten Testumgebung eingesetzt. Hierbei werden sowohl quantitative Metriken wie Genauigkeit und Vollständigkeit als auch qualitative Kriterien zur Bewertung herangezogen. Die Experimentierphase umfasst Tests unter variierenden Modellparametern und Anpassungen der Pipeline, um deren Einfluss auf die Antwortqualität zu erfassen.

Im letzten Schritt erfolgt die systematische Auswertung der gewonnenen Daten. Dabei werden Limitationen der Modelle aufgezeigt und mögliche Optimierungsansätze diskutiert. Die Dokumentation fasst sämtliche Ergebnisse zusammen und liefert Handlungsempfehlungen für den praktischen Einsatz von LLM-basierten QA-Systemen, insbesondere in ressourcenbeschränkten Umgebungen.

= Einleitung

== Motivation
Heutige #acrpl("LLM") wie GPT‑4 erreichen teils überraschend niedrige Genauigkeit im Fakten‑#acr("QA") @head-to-tail. Diese Diskrepanz zwischen Erwartung und Realität motiviert die vorliegende Arbeit. Die Zuverlässigkeit und Limitationen solcher Systeme zu untersuchen sollen hier Anhand eines Test-Environment systematisch untersucht werden.

== Zielsetzungen
- Aufbau eines wiederholbaren #acr("QA")‑Test‑Environments  
- Evaluierung mit vollständigem vs. reduziertem Kontext  
- LoRA‑basiertes Fine-Tuning auf domänenspezifischen Text  
- Systematischer Vergleich der Performance  
- Ableitung von Empfehlungen für Praxis‑Deployments

Die Arbeit gliedert sich in drei Phasen: eine Vorbereitungs­phase mit Literaturrecherche, Korpuserstellung und Methodendefinition, eine Experimentier­phase mit Implementierung und Testdurchführung sowie eine abschließende Auswertungs- und Dokumentations­phase. Auf diese Weise sollen fundierte Erkenntnisse über die tatsächliche Leistungsfähigkeit von LLMs im Question Answering gewonnen werden.

= Grundlagen und Definitionen
Zunächst werden die nötigen Grundlagen für das Verständnis der Arbeit geschaffen.
== Question‑Answering‑ Systeme
Question‑Answering‑Systeme (#acr("QA")‑Systeme) sind Anwendungen, die automatisch auf natürlichsprachliche Fragen Text­antworten liefern. Sie kombinieren Information Retrieval (z. B. Dokumentensuche) und Natural Language Processing (z. B. Named Entity Recognition, Parsing), um in einem Korpus oder internem Modellwissen die richtige Antwort zu finden @qa-bert. 

=== Arten von Wissen  
Knowledge lässt sich in verschiedene Kategorien unterteilen, die für #acr("QA")‑Systeme relevant sind. Basierend auf  *Types and qualities of knowledge* @knowledge lassen sich folgende Typen unterscheiden:

- *Factual Knowledge* (auch *Conceptual knowledge*):  
  Dieses Wissen umfasst statische Fakten und Konzepte, z. B. „Berlin ist die Hauptstadt Deutschlands“. #acr("QA")‑Systeme greifen hier häufig auf explizite Datenbanken oder Textpassagen zurück @knowledge.

- *Procedural Knowledge*:  
  Beschreibt Abläufe und Handlungsanweisungen, z. B. Kochrezepte oder Montageanleitungen. #acr("QA") im prozeduralen Bereich muss oft Schritt‑für‑Schritt antworten.

- *Metacognitive Knowledge*:  
  Umfasst Wissen über die eigenen Wissensgrenzen und -prozesse, etwa „Ich weiß, dass ich etwas nicht weiß“. Für #acr("QA") weniger direkt relevant, kann aber bei Unsicherheitserkennung helfen.

- *Semantic Knowledge*:  
  Erklärt Bedeutungen und Zusammenhänge zwischen Konzepten, z. B. Taxonomien in Ontologien. Semantisch angereicherte #acr("QA")‑Systeme nutzen dieses Wissen, um Antworten präziser zu formulieren.

- *Contextual Knowledge*:  
  Form von Wissen, das an einen bestimmten Kontext gebunden ist (z. B. aktuelle Nachrichten, persönliche Vorlieben). Open‑Domain‑#acr("QA")‑Systeme müssen dynamisch darauf zugreifen.

Wir konzentrieren uns in dieser Arbeit auf *Factual Knowledge* („Conceptual knowledge“), da aktuelle LLMs hier erhebliche Defizite zeigen. Studien belegen, dass selbst GPT‑4 im Fakten‑#acr("QA") nur ca. 40,3 % korrekte Antworten liefert, obwohl diese Informationen während Pre‑Training oft mehrfach auftauchen @head-to-tail.

=== Typen von #acr("QA")‑Systemen

Im Folgenden werden die üblichen Typen des #acr("QA") beschrieben und erläutert, welcher davon sich am besten für den bestehenden Anwendungsfall eignet.
- *Extractive #acr("QA")*: 

  Bei dieser Methode erhält das Modell eine Frage und einen zusammenhängenden Textabschnitt (Kontext). Es identifiziert dann genau den oder die Wortgruppen (Spans), die die beste Antwort enthalten. Zum Beispiel sucht ein System in einem Wikipedia-Artikel nach der Textstelle, die erklärt, wofür Einstein den Nobelpreis erhielt @rajpurkar2016squad. Extractive #acr("QA") ist besonders zuverlässig, da die Antwort wortwörtlich aus dem vorgegebenen Text stammt und so keine inhaltliche Erfindung (Halluzination) erfolgt.
  - *Arbeitsweise:* Das Modell nutzt einen Token-basierten Klassifikator, um Start- und End-Position der Antwort im Kontext vorherzusagen.
  - *Vorteile:* Hohe Präzision und Nachvollziehbarkeit; geringe Gefahr von Halluzinationen.
  - *Nachteile:* Antworten müssen wortwörtlich im Kontext stehen; keine freie Formulierung.
@qa-bert

- *Generative #acr("QA")*  
  Hier erzeugt das Modell die Antwort eigenständig aus Frage und Kontext, statt sie wortwörtlich zu übernehmen. Moderne LLMs wie GPT‑Modelle erstellen frei formulierte Fließtext-Antworten @wolf2020transformers.

- *Closed‑Book #acr("QA")*  
  Das Modell nutzt nur im Pretraining erworbenes Wissen, ohne zusätzliche Kontext-Eingabe. Typisches Beispiel sind GPT‑basierten Chatbots, die über intern gelernten Wissensspeicher verfügen @wolf2020transformers.

- *Open‑Domain #acr("QA")*  
  Systeme greifen auf ein großes Wissensreservoir (z.B. Wikipedia) zu. Ein Retriever identifiziert relevante Dokumente, die ein Reader oder Generator anschließend für die Antwort nutzt (Retrieval-Augmented Generation) @lewis2020rag.

- *Closed‑Domain #acr("QA")*  
  Beschränkt auf ein Fachgebiet (z.B. Medizin). Hier kann das System auf Domänen‑Ontologien oder spezialisierte Korpora zugreifen, um präzisere Antworten zu liefern @kwiatkowski2019nq.

- *Cross‑Lingual #acr("QA")*  
  Frage und/oder Kontext können in unterschiedlichen Sprachen sein. Benchmarks wie TyDi#acr("QA") oder ML#acr("QA") prüfen die Fähigkeit, in mehreren Sprachen zu antworten @rajpurkar2019tydiqa.

- *Semantically Constrained #acr("QA")*  
  Nutzt zusätzliche semantische Regeln oder Ontologien, um nur Antworten eines bestimmten Typs zuzulassen. Diese Form steigert die Präzision in spezialisierten Anwendungen @reimers2019sentence.

Für unseren Anwendungsfall haben wir uns für Extractive #acr("QA") entschieden, da hier die Antworten direkt als Textspans aus einem vorgegebenen Dokument extrahiert werden und somit hohe Präzision und Nachvollziehbarkeit gewährleisten. Anders als bei generativen Modellen, die freie Fließtext-Antworten erzeugen und dabei zu Halluzinationen neigen können @wolf2020transformers, sucht das Extractive‑System gezielt nach der Start‑ und Endposition der korrekten Antwort im Kontexttext, wie es beispielsweise im SQuAD‑Datensatz üblich ist @rajpurkar2016squad. So lassen sich falsche Vorhersagen einfach analysieren und korrigieren, weil der Modell‑Output immer klar auf eine Textstelle zurückzuführen ist. Zudem bedarf es kaum Prompt‑Engineering, sondern lediglich einer geeigneten HuggingFace‑Pipeline, die in Jupyter‑Notebooks effizient auf verschiedene Dokumente skaliert. Diese Kombination aus Verlässlichkeit, schneller Integrationsfähigkeit und geringem Anpassungsaufwand macht Extractive #acr("QA") für unsere Evaluierung ideal.

== Künstliche Intelligenz  
Künstliche Intelligenz (KI) ist der Oberbegriff für Technologien, die Computern ermöglichen, menschliche Denkprozesse wie Lernen, Schlussfolgern und Entscheidungsfindung zu simulieren @IBM2024_WhatIsAI. Moderne KI setzt vor allem auf Machine Learning:  
- Computer erhalten eine große Menge von Beispieldaten (z. B. frühere Käufe),  
- sie erkennen darin Muster und Zusammenhänge (z. B. welche Produkte häufig gemeinsam gekauft werden) und  
- passen ihre internen Parameter so an, dass sie Vorhersagen für neue Daten treffen können @MITSloan2020_MLExplained.  
Dieses „Musterlernen“ erlaubt es, Konsumenten individuelle Produktempfehlungen auszugeben oder Preise dynamisch anzupassen, was nachweislich die Conversion-Rate erhöht und das Kundenerlebnis verbessert @HBR2023_CX.
#figure(
  image("assets/ai-graph.svg", width: 100%),
  caption: [@McKinsey2024_StateOfAI Immer mehr Unternehmen benutzen KI um einen oder mehrere Geschäftsprozesse zu automatisieren. Seit der einfachen Verfügbarkeit von generativer KI, wurde diese auch rapide adaptiert. Im @sec:genai wird diese Technologie noch genauer beleuchtet]
)<fig:mck-ai>
== Generative AI  
<sec:genai>
#grid(
  columns: (2fr, 1.5fr),
  gutter: 10pt,
  [
Generative AI bezeichnet KI-Ansätze, die neue Inhalte wie Texte, Bilder oder Videos erzeugen können @McKinsey2024_GenerativeAI. Ausschlaggebend war das Transformer-Modell von Vaswani et al. (2017). Dieses Forscherteam bei Google Brain legte mit dem Paper _Attention Is All You Need_ den Grundstein für die heute gängigen Sprachmodelle wie ChatGPT. Sie setzten vollständig auf Self-Attention – ein Verfahren, bei dem jedes Element (z. B. ein Wort) alle anderen im Satz „gewichtet“, um die für den Kontext wichtigsten Informationen herauszufiltern und zu kombinieren @vaswani2017attention.
  ],
  figure(
  image("assets/ai-all.png"),
  caption: [Einordnung von GenAI @sas_genai_landscape2024]
)
)
Unternehmen nutzen Generative AI z.B. um in Echtzeit Produktbilder oder Werbeclips zu erzeugen, die exakt zu Nutzerpräferenzen passen. So kann z. B. eine Online-Modeplattform  automatisch Outfits in verschiedenen Stilen generieren @McKinsey2024_StateOfAI.
/*
=== Transformer‑Architektur  
Der Transformer ist die Standardarchitektur heutiger LLMs @vaswani2017attention. Er besteht aus gestapelten Encoder‑ und/oder Decoder‑Blöcken mit Self‑Attention und Feed‑Forward-Netzwerken, erlaubt paralleles Training.
$ "Attention"(Q, K, V) = "softmax"(frac(Q K^T, sqrt(d_k))) V $

$ "MultiHead"(Q, K, V) = "concat"("head"_1, dots, "head"_h) W^O $

$ "head"_i = "Attention"(Q W_i^Q, K W_i^K, V W_i^V) $
*/
=== Trainingsverfahren  
LLMs durchlaufen zwei Phasen:
- *Pretraining*  
  • Masked Language Modeling (BERT) @devlin2019bert  
  • Autoregressive Next-Token-Prediction (GPT) @wolf2020transformers  
- *Fine‑Tuning*  
  Spezialisierung auf Aufgaben oder Domänen. Moderne Systeme wie GPT-4 nutzen zusätzlich *Reinforcement Learning from Human Feedback* (RLHF) @hu2021lora.


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

*Low-Rank Adaptation (LoRA)* ist eine Methode aus dem Bereich *Parameter Efficient Fine-Tuning* PEFT, bei der nur wenige zusätzliche Gewichte trainiert werden.

Anstatt $bold(W)$ direkt zu aktualisieren, wird eine Veränderung $ Delta bold(W) $ als Produkt zweier kleiner Matrizen eingeführt:

$ bold(W) = bold(W)_0 + Delta bold(W) = bold(W)_0 + bold(A) dot bold(B) $

Dabei sind:
- $bold(A) in RR^(d times r)$
- $bold(B) in RR^(r times k)$
- $r "ll" min(d, k)$
#figure(
    image("fine-tuning.png"),
    caption: [Full‑Parameter‑Fine‑Tuning vs #acr("LoRA") @intel-ft]
)
@intel-ft zeigt, dass beim Full-Parameter-Tuning alle Gewichte (inklusive Bias) eines vortrainierten Layers direkt angepasst werden, während #acr("LoRA") die ursprünglichen Parameter einfriert und ausschließlich zwei low-rank, bzw. Matrizen A und B trainiert, deren skaliertes Produkt als Residual zum ursprünglichen Layer-Output addiert wird. Dadurch reduziert #acr("LoRA") den Speicher- und Rechenaufwand beim Fine-Tuning erheblich, da nur ein Bruchteil der Parameter trainiert werden. Das bedeutet, anstelle von $d dot k$ Parametern werden nur $(d + k) dot r$ Parameter trainiert:

$ frac((d + k) dot r, d dot k) "ll" 1 $

Beispiel: Für $d = k = 768$, $r = 8$ ergibt sich eine Reduktion auf nur ca. 2% der ursprünglichen Parameteranzahl.

- Vorteile:
  - Geringer Speicherbedarf
  - Task-spezifische Adapter lassen sich effizient laden
  - Vortrainiertes Modell bleibt unangetastet
- Nachteile:
  - Potenziell geringere Performanz bei zu kleinem $r$
  - Mehr Aufwand beim Deployment verschiedener Adapter

=== Mathematischer Vergleich

#table(
  columns: (auto, auto, auto),
  align: left,
  [*Methode*], [*Trainierbare Parameter*], [*Speicherbedarf*],
  [Full‑Tuning], [$d dot k$], [$O(d dot k)$],
  [LoRA (rank $r$)], [$(d + k) dot r$], [$O((d + k) dot r)$]
)
Da $r$ typischerweise deutlich kleiner ist als $d$ und $k$, fällt der Parameter- und Speicheraufwand bei LoRA im Vergleich zum Full-Tuning erheblich geringer aus. Dadurch eignet sich LoRA besonders für ressourcenoptimiere Umgebungen oder große Modelle.
== #acr("SQuAD")

Ein beliebter Datensatz für #acr("QA")-Systeme ist #acr("SQuAD"). Dort wurden in einem strukturierten Format über 100000 Fragen zu Wikipedia-Artikeln aufbereitet @rajpurkar2016squad.
SQuAD 2.0 ergänzt unanswerable Fragen @rajpurkar2018squad2.
/*
- Exact Match EM berechnet den Anteil exakter Übereinstimmungen
- F1-Score misst den Token-Overlap zwischen prognostiziertem und Gold-Span

$ "F1" = 2 |P ∩ G| / (|P| + |G|) $
*/
== Weitere Benchmarks
- Natural Questions dokumentiert reale Suchanfragen und ist offen für Closed-Book #acr("QA") @kwiatkowski2019nq
- Hotpot#acr("QA") erfordert Multi-Hop-Reasoning
- TyDi#acr("QA"), XQuAD und ML#acr("QA") testen multilinguale Fähigkeiten @rajpurkar2019tydiqa

== Metriken zur #acr("QA")-Bewertung

In diesem Kapitel werden die zentralen Kennzahlen erläutert, mit denen wir die Qualität von Question‑Answering-Systemen messen. Jede Metrik beleuchtet einen spezifischen Aspekt: von der reinen Worttreue bis zur semantischen Tiefe der Antwort. Für unseren Use Case sind besonders robuste Metriken wie F1‑Score und Semantic Answer Similarity (SAS) entscheidend, da sie auch bei variierenden Formulierungen zuverlässige Bewertungen ermöglichen @metrics, @sas-qa.

#definition("Accuracy")[
  Misst den Anteil aller Antworten, die als korrekt klassifiziert werden können – unabhängig von der Antwortlänge oder Position. In unserem Fall bedeutet das: Die generierte Antwort stimmt entweder exakt mit der Referenzantwort überein oder übersteigt eine definierte Schwelle semantischer Ähnlichkeit. Da jede Frage genau eine Antwort generiert, wird Accuracy hier als binäre Bewertungsmetrik verwendet. Der Einfachheit halber wird auf _halb_ korrekte Antworten verzichtet.

  $ "Accuracy" = frac("Anzahl korrekter Antworten", "Gesamtanzahl Fragen") $
]

#definition("F1-Score")[
  Das harmonische Mittel aus Precision und Recall. F1 vereint beide Perspektiven und ist besonders dann sinnvoll, wenn ein ausgewogenes Verhältnis von Genauigkeit und Vollständigkeit gefordert ist – typisch in #acr("QA"), wo man sowohl richtige als auch vollständige Antworten benötigt.

  $ "F1" = frac(2 dot "Precision" dot "Recall", "Precision" + "Recall") $
]

#definition("Exact Match (EM)")[
  Misst den Anteil der Antworten, die exakt mit den Referenzantworten übereinstimmen. EM ist besonders streng, da nur ganz genaue Textübereinstimmungen als korrekt gewertet werden. Für #acr("QA")-Systeme, die exakte Textspans ausgeben, bildet EM den härtesten Qualitätsmaßstab.

  $ "EM" = frac("Anzahl exakter Antworten", "Gesamtanzahl Fragen") $
]
#definition("Semantic Answer Similarity (SAS)")[
  Ein lernbarer semantischer Metrik-Score im Bereich $[0,1]$. #acr("SAS") bewertet, wie inhaltlich ähnlich eine generierte Antwort zur Gold-Antwort ist, selbst wenn sie anders formuliert ist. Diese Metrik ergänzt string-basierte Maße und ist in unserem Use Case wichtig, weil sie semantisch korrekte Paraphrasen erkennt @mrr.
  $ "SAS" "liegt im Intervall" [0,1] $
  Hier verwenden wir Cosine-Similariy zur Berechnung der #acr("SAS"). Die Formel hierfür lautet:
$ "cosine similarity" = frac(sum a_i b_i, (sum a_i^2)^(1/2) (sum b_i^2)^(1/2)) $  
]


Diese Metriken kombiniert erlauben eine umfassende Beurteilung:  
- *Accuracy* bietet eine einfache Erfolgsquote in binärer Form.  
- *F1* bewertet Token‑ und Span‑Ebene direkt.  
- *EM* prüft wortwörtliche Korrektheit.  
- *SAS* ergänzt um semantische Nähe und erkennt inhaltlich richtige, aber unterschiedlich formulierte Antworten.

Für unseren Use Case ist #acr("SAS") zentral, da sie sowohl Teil‑ als auch semantische Übereinstimmung messen und somit robust gegen kleine Formulierungsunterschiede sind.


= Realisierung

/*
== Umsetzung eines #acr("QA")-Testframeworks

Für die Reproduzierbarkeit und Skalierbarkeit unseres QA‑Testframeworks setzen wir auf folgende technische Infrastruktur:

- *Programmiersprache & Umgebung:*  
  Python 3.8+ in Jupyter-Notebooks oder Colab.

- *Kernbibliotheken:*  
  - `transformers` für Modell‑Loading und Inferenz  
  - `datasets` zum Laden und Verarbeiten von QA‑Datensätzen (SQuAD, NaturalQuestions)  
  - `peft` für PEFT/LoRA‑Fine‑Tuning  
  - `evaluate` für standardisierte Metriken (EM, F1, MRR)  

- *Logging & Monitoring:*  
  Weights & Biases (`wandb`) für Hyperparameter‑Tracking, Loss‑Kurven und Metriken.

- *Versionierung & Reproduzierbarkeit:*  
  - Git-Repository mit `requirements.txt` zur Paketverwaltung  
  - Festlegung von Zufallskeimen:

- *Notebook‑Struktur:*  
  1. *Datenaufbereitung:*  
     Einlesen des Korpus (`complete_context.txt`, `question-sets/q_v2.json`)  
  2. *Chunking & semantisches Ranking:*  
     Context in Abschnitte teilen und Top‑K‑Chunks per Sentence‑Transformer auswählen  
  3. *Modellinferenz:*  
     QA‑Pipeline (`deepset/roberta-base-squad2`) für FullContext und ReducedContext  
  4. *LoRA‑Fine‑Tuning:*  
     Adapter mittels `peft` hinzufügen, Training mit Kontext‑Chunks als MLM‑Daten  
  5. *Evaluation:*  
     EM, F1, MRR berechnen mit `evaluate`  
  6. *Visualisierung:*  
     Barplots, Heatmaps, Trainingskurven  
*/

== Textkorpus

Zunächst wurde ein umfangreicher Textkorpus zusammengestellt. Als Thema wurde *Judo* gewählt, da sich der Entwickler gut damit auskennt und Judo sich für Faktenwissen-Tests eignet. Es gibt zahlreiche Details – von Technikklassifizierungen über historische Daten bis hin zu Wettkampfergebnissen, die sich gut abfragen lassen. Dabei wurden für den Textkorpus folgende Quellen gewählt:


#set table(
  stroke: 0.5pt,
  gutter: 0.1em,
  fill: (x, y) => if y == 0 { gray.lighten(40%) },
  inset: (left: 0.5em, right: 0.5em),
)

#show table.cell.where(y: 0): set text(weight: "bold")

#table(
  columns: (2fr, 2.2fr),
  [Quelle], [Begründung],
  [https://en.wikipedia.org/wiki/Judo], [Wikipedia liefert eine umfassende Übersicht über Geschichte, Regeln und Begriffe.],
  [https://en.wikipedia.org/wiki/List_of_judo_techniques], [Detaillierte Auflistung aller Techniken, ideal für technische Beispiele.],
  [https://en.wikipedia.org/wiki/List_of_judoka], [Informationen zu bedeutenden Judoka, nützlich für biografische Fragen.],
  [https://martialarts.fandom.com/wiki/Judo], [Populärkulturelle Perspektive und weiterführende Details.],
  [https://chas-ma.com/JudoManual/Chapter_2%28HistoryofJudo%29.pdf], [Fachlicher PDF-Quelltext zur historischen Entwicklung von Judo.],
  [https://www.ijf.org/history], [Offizielle Historie der International Judo Federation (IJF).],
  [https://blackbelttrek.com/judo-vs-jiu-jitsu-the-ultimate-comparison/], [Vergleich mit Jiu-Jitsu, um Abgrenzungen und historische Zusammenhänge zu verdeutlichen.],
)

== Fragesätze

Die Fragesätze liegen in einem flachen JSON-Format vor, bei dem jedes Objekt genau die Felder  
`question` und `answer` enthält. Im Laufe der Arbeit wurden drei Prototypen entwickelt und evaluiert:

*Prototyp 1 – verbos und unstrukturiert*  
Im ersten Ansatz enthielten die Antworten oft vollständige Sätze oder sogar ganze Absätze.  
Diese verbosen Rückgaben führten zu schlechter Performance, da das QA-Modell auf kurze, prägnante Antworten optimiert ist.  
Zudem waren manche Fragen nicht rein auf Faktenwissen ausgelegt, sondern erforderten etwas längere Erklärungen, was die Auswertung zusätzlich erschwerte.

*Prototyp 2 – atomare Antworten*  
Um die Performance deutlich zu steigern, wurden die Fragen so angepasst, dass jede Antwort *atomar* ist – also nur das absolut Notwendige enthält, _ground truth_.  
Beispiel: Anstelle „Judo bedeutet ‚der sanfte Weg‘ und wurde 1882 von Kanō Jigorō gegründet“ steht nur noch „der sanfte Weg“.  
Durch diese Reduktion auf einfache Stichwortantworten verringerte sich der Fehleranteil spürbar.

*Prototyp 3 – Erweiterung und Strukturierung*  
Im dritten Schritt wurde nicht nur die Atomizität beibehalten, sondern auch das Volumen der Fragen erhöht und eine zusätzliche Kategorisierung eingeführt.  
Alle Fragesätze wurden anhand definierter Heuristiken in die drei Schwierigkeitsstufen *Easy*, *Medium* und *Hard* sortiert.  
Die Kriterien hierfür – wie Termfrequenz, Antwortlänge oder semantische Komplexität – werden im Abschnitt „Klassifikation nach Schwierigkeit“ ausführlich erläutert.  
Diese strukturierte Vorgehensweise erlaubt eine gezieltere Analyse des Modellverhaltens je nach Fragenprofil.

== Prototypen und Experimente

Dieser Abschnitt dokumentiert die iterative Entwicklung und Evaluierung verschiedener Ansätze zur Beantwortung von Fragen im Kontext eines umfangreichen Judo-Korpus. Ziel war es, die Antwortgenauigkeit zu maximieren und gleichzeitig die Effizienz des Systems zu verbessern.

=== Baseline: Vollständiger Korpus

*Vorgehen*:  
Für jede Frage wurde der gesamte Textkorpus (bestehend aus mehreren Quellen) als Kontext an das Frage-Antwort-Modell übergeben. Dieser Kontext wurde in einer Text-Datei abgelegt und beinhaltet die o.g. Webseitinhalte, die einfach aneinander konkateniert wurden. Dabei erreicht er eine Länge von ca. 140 000 Zeichen.

*Beobachtungen*:
- *Laufzeit*: Sehr hohe Antwortzeiten aufgrund des umfangreichen Kontextes: Jede Frage benötigt etwa 2 Minuten Rechenzeit auf dem Laptop des Entwicklers. Später wurde das Jupyter-Notebook auf Google Colab ausgeführt, was eine deutlich schnellere Laufzeit ermöglichte (ca. 10-20x schneller).
- *Genauigkeit*: Solide, jedoch nicht optimal, da irrelevante Informationen den Kontext evtl. verwässern. 
- *Token-Limit*: Gefahr des Überschreitens des maximalen Token-Limits des Modells, was zu abgeschnittenen Kontexten führen kann. Das verwendete Modell deepset-roberta-squad2


== Kontextreduktion mittels semantischem Chunking

In diesem Abschnitt wird ausführlich beschrieben, wie der Umfang des Textkorpus systematisch reduziert wurde, um sowohl die Effizienz des QA-Systems zu verbessern als auch die Genauigkeit weitestgehend zu erhalten. Wir erläutern die Motivation, das methodische Vorgehen, die experimentelle Konfiguration, stellen die Ergebnisse grafisch dar und diskutieren zentrale Beobachtungen.

=== Motivation

Der ursprüngliche Textkorpus setzt sich aus verschiedenen Quellen zusammen (Wikipedia-Artikel, PDF-Kapitel, Fandom- und IJF-Webseiten) und umfasst mehr als 140 000 Zeichen. Bei Abfragen unter Verwendung des gesamten Kontexts zeigte sich, dass die Verarbeitung deutlich länger dauerte und das Modell aufgrund großer Mengen an irrelevanten Informationen weniger präzise antwortete. Ziel der Kontextreduktion ist es daher, den Korpus so stark wie möglich zu verkleinern, ohne wichtige Antworten zu verlieren. Dafür setzen wir semantisches Chunking ein, um nur inhaltlich relevante Abschnitte auszuwählen.

=== Methodik

- Segmentierung in Chunks  
  Der vollständige Korpus wurde in Absätze bzw. thematische Einheiten unterteilt und ergab zunächst 378 Chunks.  
- Filterung nach Mindestlänge  
  Nur Chunks mit mindestens 20 Wörtern blieben erhalten, um triviale oder zu kurze Abschnitte auszuschließen. Nach diesem Filter verblieben 215 Chunks, die als *potenziell relevant* galten.

=== Semantische Ähnlichkeitsberechnung

- Embedding-Repräsentation  
  Für jeden der 215 Chunks erzeugen wir ein *SBERT-Embedding* (Modell: `all-MiniLM-L6-v2`). Ebenso wird jede Frage in ein SBERT-Embedding überführt.  
- Cosine-Similarity  
  Für jede Frage berechnen wir die Cosine Similarity zwischen dem Frage-Embedding und jedem Chunk-Embedding. Anschließend sortieren wir die Chunks nach ihrem Similarity-Score ( höherer Score → größere semantische Relevanz).  
- Auswahl der Top-K Chunks  
  Für verschiedene Reduktionsstufen wählen wir jeweils die *Top K* Chunks aus, um den reduzierten Kontext zu bilden. K entspricht einem Prozentsatz der 215 relevanten Chunks (z. B. 75 % von 215 ≈ 161).

=== Experimenteller Versuchsaufbau

Für vier Kontextgrößen (Vollkontext und drei Reduktionsstufen) wurden folgende Abläufe realisiert:

- *Full Context*  
  Der komplette Korpus (alle 378 Chunks) dient als Kontext.  
  – Ergebnis: *Accuracy* = 54/78 = 69.2 %.

- *75 % der relevanten Chunks*  
  K = 0.75 × 215 = 161 Chunks.  
  – Cosine-Scores der ausgewählten Chunks liegen zwischen 0.7320 (höchste Relevanz) und 0.4622 (niedrigste in den Top 161).  
  – Reduzierter Kontext: 108 619 Zeichen (Reduktion um 23.32 %).  
  – *Accuracy*: 49/78 = 62.8 %.

- *50 % der relevanten Chunks*  
  K = 0.50 × 215 = 108 Chunks.  
  – Cosine-Scores liegen zwischen 0.7320 und 0.5442 für die Top 108.  
  – Reduzierter Kontext: 76 622 Zeichen (Reduktion um 45.91 %).  
  – *Accuracy*: 39/78 = 50.0 %.

- *25 % der relevanten Chunks*  
  K = 0.25 × 215 = 54 Chunks.  
  – Cosine-Scores liegen zwischen 0.7320 und 0.6133 für die Top 54.  
  – Reduzierter Kontext: 45 325 Zeichen (Reduktion um 68.00 %).  
  – *Accuracy*: 38/78 = 48.7 %.

*Hinweis:* Je kleiner der Kontext, desto schneller laufen die QA-Anfragen, da das Modell weniger Text verarbeiten muss.


== Ergebnisse und Visualisierung

Die folgenden Abbildungen veranschaulichen  
1. die *Accuracy* in % für jede Reduktionsstufe und  
2. den Zusammenhang zwischen prozentualer Kontextreduktion und Accuracy.  

Die Farben basieren auf einer Rot–Gelb–Grün-Skala, wobei niedrige Accuracy-Werte rot und hohe Accuracy-Werte grün eingefärbt werden.

#figure(image("assets/KontextVsAccBar.png"), caption: "Accuracy bei unterschiedlicher Kontextreduktion (Full, 75 %, 50 %, 25 %) – farbcodiert von Rot (niedrig) bis Grün (hoch).")

#figure(image("assets/KontextVsAcc.png"), caption: "Zusammenhang: Prozentuale Kontextreduktion vs. Accuracy mit linearer Trendlinie.")

*Interpretation der Resultate*  
- *Full Context* (0 % Reduktion): Höchste Accuracy (69.2 %).  
- *75 % Chunks* (23.32 % Zeichenreduktion): Accuracy sinkt moderat auf 62.8 %.  
- *50 % Chunks* (45.91 % Zeichenreduktion): Accuracy fällt auf 50.0 %.  
- *25 % Chunks* (68.00 % Zeichenreduktion): Accuracy liegt bei 48.7 %, der Informationsverlust zeigt deutliche Auswirkungen.


== Beobachtungen

- *Starker Genauigkeitsverlust unter 50 % Reduktion*  
  Ab 50 % Reduktion sinkt die Accuracy auf 50.0 % oder darunter, was für faktische QA-Anwendungen zu ungenau ist. Wenn der für eine bestimmte Frage relevante Teil des Textkorpus nicht mehr im reduzierten Kontext enthalten ist, entstehen Nonsense-Antworten. Diese wurde hier besonders bei der 50% Schwelle bemerkbar, wo teilweise auch gar keine Antwort geliefert wurde. 

- *Semantische Qualität der Chunks*  
  Top-Chunks (Score > 0.7) enthalten häufig Definitionen oder Listen mit QA-relevanten Fakten (z. B. Judo-Grundbegriffe). Chunks mit Scores < 0.5 liefern eher allgemeine oder philosophische Inhalte und sind weniger hilfreich.  

- *Kompromiss zwischen Vollständigkeit und Präzision*  
  Eine adaptive Auswahlstrategie könnte sinnvoll sein, indem man beispielsweise alle Chunks mit einem Score ≥ 0.6 einbezieht, statt fixe Prozentsätze zu verwenden.  

- *Optimierungsmöglichkeiten*  
  - Adaptive K-Wahl: Anstatt fixer Prozentsätze (75 %, 50 %, 25 %) könnte die Chunk-Anzahl dynamisch anhand der Score-Verteilung gewählt werden.  
  - Strukturiertes Context-Building: Chunks, die Überschriften oder Definitionen enthalten, priorisieren, um schnelle Treffer bei einfacheren Fragen zu erzielen.

Die semantische Chunk-Reduktion erweist sich als effektive Methode, um QA-Performance und Effizienz zu steigern, solange man nicht unter eine kritische Chunk-Schwelle (≈ 50 %) fällt. Bei 75 % Reduktion (– 23.32 %) erreicht man mit 62.8 % Accuracy einen guten Kompromiss. Weitere Optimierungen sind über adaptive Auswahlkriterien realisierbar, um sowohl Accuracy als auch Effizienz zu maximieren.  

=== Fine-Tuning mit Low-Rank Adaption (LoRA)

*Vorgehen*:
- Das vortrainierte Modell wurde mittels LoRA auf den spezifischen Judo-Korpus feinjustiert.
- LoRA ermöglichte effizientes Fine-Tuning durch Anpassung einer kleinen Anzahl von Parametern, wodurch der Speicherbedarf reduziert wurde.

Für diesen konkreten Usecase hat das Finetuning allerdings keinen Genauigkeitszuwachs im Vergleich zum Basis-Modell bewirkt. Es wurden hier erneut 
#figure(image("assets/finetuned.png"), caption: "Fine-Tuning liefert in diesem Fall zwar teils andere und subjektiv bessere Antworten, erhöht aber nicht die Accuracy")
=== Evaluation der Modelle

In der ersten Evaluierungsphase kam eine *rein stringbasierte* Methodik zum Einsatz, bei der Antworten als korrekt galten, wenn sie exakt mit den Musterantworten übereinstimmten oder eine hohe Zeichen­übereinstimmung (z. B. ≥ 80 %) aufwiesen. Dieses Verfahren zeigte allerdings deutliche Schwächen:

- *Synonyme und Namensvarianten* werden nicht erkannt, z. B. „Jigoro Kano“ vs. „Kanō Jigorō“ oder „International Judo Federation“ vs. „IJF“.
- *Unterschiedliche Formulierungen und Satzstellungen* gelten als falsch, z. B. „sanfter Weg“ vs. „der sanfte Weg“ oder „1882 gründete Kanō Jigorō den Kōdōkan“ vs. „Der Kōdōkan wurde 1882 von Kanō Jigorō gegründet“.
- *Mehrdeutigkeit bei offenen Fragen*, etwa „Nenne einen Hüftwurf“, erlaubt mehrere gültige Antworten, die stringbasiert schwer zu erfassen sind.

Aus diesen Gründen wurde die Evaluierung auf eine *semantische* Methodik umgestellt. Anstelle des Fuzzy Matching wird die *Cosine Similarity* zwischen der Einbettung der Modell­antwort und der Einbettung der Referenz­antwort herangezogen. So können inhaltlich identische, aber unterschiedlich formulierte Antworten zuverlässig als korrekt bewertet werden.

Zur ganzheitlichen Beurteilung der Prototypen wurden folgende Metriken definiert:

- *Antwortgenauigkeit*:  
  Semantische Ähnlichkeit zwischen erwarteter und generierter Antwort, gemessen via Cosine Similarity (Schwellenwert z. B. 0.70).  
- *Laufzeit*:  
  Durchschnittliche Zeit, die das Modell zur Beantwortung einer einzelnen Frage benötigt.  
- *Ressourcennutzung*:  
  Speicher- und Rechenzeit­aufwand während der Inferenz, um Effizienz und Skalierbarkeit abzuschätzen.

== Klassifikation nach Schwierigkeit

In Anlehnung an das *head-to-tail*-Paper wurde ein mehrstufiges Schema entwickelt, um die Fragen systematisch in *Easy*, *Medium* und *Hard* zu unterteilen. Ziel war es, eine nachvollziehbare Balance zwischen *häufig vorkommendem Basiswissen* und *tiefgehenden Spezialfragen* herzustellen. Die Einteilung erfolgte in einem iterativen Prozess, bei dem quantitative Heuristiken mit qualitativen Einschätzungen kombiniert wurden.

Die Klassifikation basiert auf vier zentralen Heuristiken:

- *Frequenz und Prominenz* 
Zunächst wurde die Verteilung von Schlüsselbegriffen im Korpus analysiert. Häufig zitierte Begriffe wie *judo*, *Kanō Jigorō* oder *Kōdōkan* markieren grundlegende Konzepte und bilden damit das Fundament für *Easy*-Fragen. Selten auftretende oder nur in Fachabschnitten erwähnte Terme weisen dagegen auf eine höhere Schwierigkeit hin.

- *Informationsdichte und Antwortkomplexität*  
Der Umfang und die Struktur der erwarteten Antworten wurden berücksichtigt: Sehr kurze, prägnante Antworten (z. B. ein oder zwei Wörter) kennzeichnen Fragen der Stufe *Easy*. Im Gegensatz dazu erfordern mittellange Antworten in zusammengesetzten Fachbegriffen (*Medium*), während lange oder mehrteilige Antworten—etwa diejenigen, die Kombinationen von Datum, Ort und Person enthalten—typischerweise als *Hard* eingestuft wurden. In der Praxis zeigte sich, dass übermäßig komplexe Frageformate die QA-Performance deutlich verschlechtern und daher eher vermieden wurden.

- *Kognitive Anforderungen und Kontextverknüpfung*  
Nicht nur die Länge, sondern auch der Grad der gedanklichen Verknüpfung spielt eine Rolle: 

*Easy*-Fragen fordern reines und gängiges Faktenwissen.

*Medium*-Fragen setzen eine Einordnung ins historische oder terminologische Umfeld voraus (z.B. _In welchem Jahr wurde der Kōdōkan gegründet?_). 

*Hard*-Fragen verlangen die Verknüpfung mehrerer Aspekte, etwa wenn es gilt, eine Person direkt mit einem historischen Ereignis zu verbinden.

- *Semantische Ambiguität*  
Schließlich wurde geprüft, wie eindeutig eine Antwort im Text lokalisiert ist. Antworten, die mehrfach in identischer Form auftauchen, neigen zu moderater Schwierigkeit (*Medium*), da die korrekte Stelle nicht immer sofort ersichtlich ist. Einzigartige oder sehr verstreut gelagerte Antwortpassagen erhöhen die Schwierigkeit auf *Hard*, weil das Modell den relevanten Span präzise identifizieren muss.

Die Fragen wurden manuell nach definierten Heuristiken in Schwierigkeitsgrade unterteilt. Mit 36 % Easy, 24 % Medium und 40 % Hard ergibt sich eine ausgewogene Verteilung, die den Anforderungen des Use Cases genügt. Das entspricht je 28, 19 und 31 Fragen, also in Summe 78. Zuvor wurden einige Fragen entfernt, die z.B. nicht objektiv beantwortbar waren oder andere Mängel aufwiesen.

== Beispiele der Einordnung

Um das Schema anschaulich zu machen, hier exemplarische Fragestellungen je Kategorie:

*Easy*  

Fragen aus dem Bereich der grundlegenden Terminologie und Farben, die in Einsteigerliteratur und Zusammenfassungen häufig erwähnt werden:  
– _What does judo mean?_  
– _What color belt do novices wear?_  

*Medium*  

Fragen, die den historischen oder organisatorischen Kontext erfordern und moderat komplexe Antworten liefern:  
– _From which martial art did judo originate?_  
– _What influenced European and Russian judoka?_  

*Hard*

Tiefgehende Detailfragen zu speziellen Techniken, historischen Figuren oder seltenen Regelaspekten, die nur in Fachtexten oder speziellen Quellen zu finden sind:  
– _Name a forbidden sacrifice throw in competition._  
– _Who succeeded Aldo Torti as IJF president?_  

Aufgrund der überschaubaren Fragenanzahl war die Klassifikation hier manuell möglich. In zukünftigen Tests von QA-Systemen wäre es sinnvoll diese Einordnung durch ein LLM durchzuführen. Dies wurde hier ebenfalls probiert, allerdings hatte das dabei verwendete LLM Schwierigkeiten die Fragen konsistent nach den definierten Heuristiken zu klassifizieren.


= Evaluierung
<cos>
In diesem Abschnitt begründen wir die Wahl der verwendeten Metrik für das Question-Answering-System. Wir fokussieren uns ausschließlich auf die #acr("SAS"), gemessen als Cosine Similarity zwischen Antwort-Embeddings, mit einem Schwellenwert von 0.7. 

== Warum nur SAS?

Für QA-Systeme, die in einem homogenen Korpus kurze, atomare Fakten abfragen, sind stringbasierte Metriken wie *Exact Match* (EM) oder der tokenbasierte *F1-Score* grundsätzlich einfach zu implementieren. Allerdings zeigen sich folgende Nachteile:

- *String-Variationen*:  
  Kleinste Unterschiede in Groß-/Kleinschreibung oder Präpositionen („sanfter Weg" vs. „der sanfte Weg") führen bei EM oft zu _falsch_.  
- *Paraphrasen*:  
  In vielen Fällen ist eine inhaltlich korrekte Paraphrase (_maximum efficiency, minimum effort_ statt _maximum efficient use of energy_) möglich, wird aber von reinen String-Vergleichen nicht erkannt.  
- *Fehleinschätzung von Teilantworten*:  
  Der F1-Score auf Token-Ebene kann zwar Teilkorrektheit bewerten, nimmt aber an, dass beide Antworttexte dieselben Token-Vokabulare verwenden (Stoppwörter, Zeichensetzung etc.).

Durch den Einsatz von #acr("SAS") und Cosine Similarity in Kombination mit der Bibliothek sentence-transformers werden genau diese Einschränkungen umgangen:
#pagebreak()
1. Robustheit gegen Paraphrasen  

   #acr("SAS") vergleicht semantische Embeddings. Zwei unterschiedlich formulierte, aber inhaltlich identische Antworten erzielen eine hohe Cosine-Similarity ($>= 0.7$).  

2. Toleranz gegenüber kleinen Abweichungen  

   Selbst wenn Wörter weggelassen oder ergänzt werden („Judo-Anzug" vs. „Judo-Uniform"), bleiben semantisch nahe Embeddings eng beieinander. Stringmetriken würden hier häufig scheitern.

3. Einfachheit der Umsetzung  

   Mit einem vortrainierten SBERT-Modell (z. B. `all-MiniLM-L6-v2`) ist es in wenigen Zeilen möglich, jede Modellantwort und die Referenzantwort in Vektoren zu überführen und die Cosine Similarity zu berechnen.  

Aus diesen Gründen haben wir uns entschieden, ausschließlich #acr("SAS") mit einem festen Schwellenwert von 0.7 als alleiniges Bewertungsverfahren einzusetzen.

== Implementierung von SAS

Für jede Frage gehen wir wie folgt vor:

1. Wir erstellen die Embeddings für die Referenzantwort $A_"gold"$ und für die Modellantwort $A_"pred"$ mittels eines SBERT-Modells:  
   $ bold(e)_"gold" = "SBERT"(A_"gold"), quad bold(e)_"pred" = "SBERT"(A_"pred") $
   
2. Die Cosine Similarity zwischen den beiden Vektoren wird berechnet als:  
   $ "sim"(bold(e)_"gold", bold(e)_"pred") = frac(bold(e)_"gold" dot bold(e)_"pred", norm(bold(e)_"gold") norm(bold(e)_"pred")) $
   wobei der Skalarprodukt im Zähler und das Produkt der Normen im Nenner steht.

3. Die Antwort gilt als korrekt, wenn  
   $ "sim"(bold(e)_"gold", bold(e)_"pred") >= 0.7 $
   
4. Andernfalls wird sie als falsch klassifiziert.

== Begründung des Schwellenwerts 0.7

Der Schwellenwert von 0.7 wurde folgendermaßen bestimmt:

- Einschluss semantischer Äquivalenz:  
  In internen Testreihen zeigte sich, dass Paraphrasen und Synonyme meist eine Cosine Similarity $>= 0.7$ erreichen.  
- Ausschluss zufälliger Koinzidenzen:  
  Werte deutlich unter 0.7 (z. B. 0.5–0.6) traten bei thematisch verwandten, aber inhaltlich unterschiedlichen Phrasen auf (z. B. „throwing" vs. „grappling").  
- Abwägung Präzision vs. Recall:  
  Ein höherer Schwellenwert (z. B. 0.9) hätte zu streng agiert und korrekte, aber leicht variierte Formulierungen als falsch gewertet.  
  Ein niedrigerer Schwellenwert (z. B. 0.6) hätte zu viele semantisch entfernte Phrasen als korrekt akzeptiert.  
  Die Wahl von 0.7 balanciert beide Effekte aus und liefert in unseren Validierungssets das beste F1-Ergebnis.

#box(
  fill: gray.lighten(80%),
  stroke: gray,
  inset: 6pt,
  "Nichtsdestotrotz führt diese semantische Evaluierungsmethodik in ca. 10–20% der Fälle immer noch zu Fehleinschätzungen, die manuell korrigiert werden müssen."
) 


== Hinweise 
- Vorverarbeitung:  
  Vor der Embedding-Berechnung wurden die Texte größtenteils normalisiert (Trimmen, Entfernen unnötiger Leerzeichen), um inkonsistente Tokenisierung zu reduzieren.  
- Auswertung:  
  Beim Reporting der Ergebnisse wird die Accuracy (Anteil richtig klassifizierter Fragen) berechnet als  
  $ "Accuracy" = frac("Anzahl der Fragen mit sim" >= 0.7, "Gesamtanzahl Fragen") times 100% $

== Zusammenfassung

Durch die ausschließliche Verwendung von #acr("SAS") (Cosine Similarity $>= 0.7$) erreichen wir:  
- Hohe Semantische Robustheit: Erlaubt vielfältige, aber inhaltlich korrekte Antwortvariationen.  
- Einfache Implementierung: Nur wenige Zeilen Code und eine einzige externe Abhängigkeit (`sentence-transformers`).  
- Stabile Evaluation ohne das Rauschen, das stringbasierte Metriken bei kleinen Änderungen verursachen.  
- Klare Entscheidungsbasis durch einen festen Schwellenwert, der in Validierungs-Experimenten empirisch gerechtfertigt wurde.

Mit dieser Metrik stellen wir sicher, dass das QA-Modell nicht nur wortwörtlich korrekt antwortet, sondern vor allem inhaltlich stimmige und kontextuell passende Antworten liefert.

= Analyse falsch beantworteter Fragen

In diesem Kapitel werden systematisch Fragen analysiert, die das QA-System nicht korrekt beantwortet hat. Ziel ist es, zu prüfen, ob die erhaltenen Antworten tatsächlich falsch sind, an welcher Stelle im Kontext das Modell sie gefunden hat und welche Ursachen dafür verantwortlich sein könnten. Anschließend werden mögliche Verbesserungen diskutiert. Dabei liegt der Fokus auf Antworten die zwar inkorrekt, aber plausibel sind. Das hilft dabei die _Gedanken_ und Muster zu verstehen nach denen das Modell agiert, bzw. wo es Schwierigkeiten hat.

Dabei orientieren wir uns an der zuvor vorgenommenen Einteilung in easy, medium und hard fragen, inspiriert von @head-to-tail.
== Easy-Fragen

Die folgenden Easy-Fragen wurden vom Modell fehlerhaft oder ungenau beantwortet. Da Easy-Fragen grundlegendes Faktenwissen abfragen, bzw. oft mehrmals im Textkorpus vorkommen, ist hier das Erwartungsniveau hoch.

==== _What is the objective of judo?_

- Expected: throw, pin, or submit opponent  
- Span: _free practice_ (Start: 17829, End: 17842)
- Similarity Score: 24.82


#underline[Prüfung der Antwort:]
  
_Free practice_ (jp.: randori) ist nicht das Ziel eines Kampfes, sondern eher das Ziel einer Trainingseinheit bzw. deren Hauptfokus. Die Frage richtet sich jedoch auf das Ziel eines Wettkampfes. Die Antwort wurde aus der Passage _Kano's emphasis on randori (free practice) in Judo_ extrahiert.


#underline[Mögliche Ursachen:]

 Verwechslungsgefahr ähnlicher Phrasen: In der Nähe der Definition des Wettkampf-Ziels steht die Erwähnung vom Fokus einer Trainingseinheit.

Verbesserungsmöglichkeit: Präzisierung durch zusätzliche Schlagworte: Frage eventuell als _What is the objective in a judo competition?_ oder _How to win a judo match?_ formulieren, um klar auf Wettkampfaspekte hinzuweisen.  

==== _Who is the person performing the throw?_

- Expected: tori  
- Span: _judoka_ (Start: 4912, End: 4918)
- Similarity Score: 28.81


#underline[Prüfung der Antwort:]
  
_Judoka_ ist ein allgemeiner Begriff für Personen, die Judo machen und funktioniert als Oberbegriff. Die exakte Bezeichnung, die in der Frage gewünscht ist, lautet _tori_. Die Antwort ist daher zwar prinzipiell korrekt, aber nicht präzise.


#underline[Mögliche Ursachen:]

 Generalisierung durch das Modell:  Häufig spricht man von _Judoka_ und seltener von dem speziellieren Begriff _tori_, also de Judoka der die Technik ausführt.


#underline[Verbesserungsvorschläge:]
  
- Einführung eines Fachbegriffs-Lexikons: Eine Nachschlage-Liste bereitstellen, die das Modell bei Antworten zwingt, zwischen generischen und spezifischen Termini zu unterscheiden (z. B. _tori_ vs. _judoka_).  
- Frage umformulieren: Mit _What is the specific Japanese term for the person performing the throw?_ das Modell noch stärker auf Fachbegriffe lenken.



#underline[Verbesserungsvorschläge:]
  
- Kontextgewinnung verfeinern: Eine semantische Nachbearbeitung einführen, die prüft, ob der gefundene Span überhaupt eine Person bezeichnet. Wörter wie _philosophy_ können so automatisch ausgeschlossen werden.  
- Regex-Pattern für Personennamen: Antworten, die keine Personennamen oder spezifische Fachbegriffe (hier _uke_) darstellen, sollten verworfen und nach einer neuen Top-Span-Auswahl gesucht werden.

==== _Name a shime-waza technique._ / _Name a kansetsu-waza technique._ / _Name an osaekomi-waza technique._ 

Bei diesen drei Fragen kam es zu einem ähnlichen Fehler:
- Korrekte Antworten wären z.B. Juji-jime, Ude-garami, Kesa-gatame
- Erhalten wurden die Antworten _throwing_ bzw. _throwing techniques_


#underline[Prüfung der Antwort:]

Alle drei Fragen verlangen spezifische Techniken aus unterschiedlichen Kategorien: Würgegriffe (shime-waza), Hebelgriffe (kansetsu-waza) und Haltegriffe (osaekomi-waza). Die erhaltene Antwort _throwing_ (bzw. _throwing techniques_) bezieht sich jedoch auf _nage-waza_ (Wurftechniken) und ist damit falsch.

#underline[Mögliche Ursachen:]

1. Falsche Kategoriereferenz: Im Korpus gibt es Überschneidungen bei den Domain-Begriffen (_throwing techniques_, _grappling techniques_, _waza_), und das Modell scheint kurzfristig die nächstbeste Technik-Kategorie (_throwing_) ausgewählt zu haben, anstatt die korrekte Unterkategorie abzufragen.  
2. Nicht spezifizierte Frageformulierung: Weil die Frage nur _Name a shime-waza technique_ lautet, besteht keine implizite Beschränkung auf eine konkrete Liste, und das Modell weicht auf die nächstliegende Kategorie aus, die im Kontext häufiger vorkommt.


#underline[Verbesserungsvorschläge:]

- Das Hauptproblem bei der Auswertung, ist dass es viele mögliche korrekte Antworten gibt, und selbst eine semantische Evaluierungsmethode wie Cosine Similarity (@cos) wahrscheinlich falsch evaluiert. Es wäre daher sinnvoll für zukünftige Iterationen solche fragen entweder völlig wegzulassen oder eine komplette Liste der möglichen Antworten in dem _answer_-Feld der JSON-Datei abzulegen. 

==== _Is judo mixed-sex?_

- Expected: no  
- Span: _Mixed-sex_ (Start: 59806, End: 59815)
- Similarity Score: 18.51


#underline[Prüfung der Antwort:]
  
Die Frage verlangt eine Ja-/Nein-Antwort: Im modernen Wettkampf ist Judo getrennt nach Geschlechtern (Männer- und Frauenwettbewerbe), also _no_. Die Antwort _Mixed-sex_ deutet darauf hin, dass das Modell eine generische Aussage über gemischte Trainingsgruppen zurückgegeben hat, aber nicht erkannte dass es sich um eine Ja-/Nein-Antwort handelt.


#underline[Mögliche Ursachen:]

 Question-Answering-Modelle wie Roberta-Bert sind auf Extractive-QA optimiert. Eine Ja-/Nein-Antwort ist daher oft nicht direkt aus dem Textkorpus extrahierbar.


#underline[Verbesserungsvorschläge:]
: Frage offen umformulieren, bzw. geschlossene Fragen weglassen/vermeiden.

==== _What does judogi translate to?_  

- Expected: judo attire  
- Span: _uniform_ (Start: 58252, End: 58259)
- Similarity Score: 45.15


#underline[Prüfung der Antwort:]
  
_Uniform_ ist im weitesten Sinne korrekt, aber nicht exakt: _judogi_ bezeichnet wörtlich _Judo-Bekleidung_ bzw. _Judo-Anzug_. Die Antwort _uniform_ ist also nicht genau genug, wenn die Begriffsspezifikation gefordert ist.


#underline[Mögliche Ursachen:]
  
1. Generalisierung durch das Modell: Bei Übersetzungen wählt das Modell häufig einen allgemeineren Begriff, ähnlich wie bei der Unterscheidung in Frage
2. Kontextdominanz synonym verwendeter Wörter: _Judo uniform_ wird oft synonym eingesetzt, sodass das Modell _uniform_ extrahiert und _judo_ weglässt.

Verbesserung: Ergänzte Frage: _What is the literal translation of ‘judogi’?_ zielt auf eine wortgetreue Übersetzung ab.  

==== _What is the traditional judo attire made of?_  

- Expected: strong white cloth  
- Span: _kimono_ (Start: 100679, End: 100685)
- Similarity Score: 20.56

#underline[Prüfung der Antwort:]

Ein _kimono_ ist ein traditionelles japanisches Gewand, wird aber auch für Judoanzüge verwendet. Die Frage bezieht sich auf das Material, nicht auf ein Synonym oder den Oberbegriff. Die Antwort _kimono_ ist naheliegend aber unpräzise, bzw. leicht fehlgeleitet.

#underline[Mögliche Ursachen:]

Frage nicht ausreichend präzise formuliert. _Stattdessen wäre z.B. What type of fabric is judo attire made of?_ Da _traditional_ oft mit _kimono_ in Verbindung gebracht wird würde es Sinn ergeben dies nicht extra zu erwähnen um das Modell nicht fehlzuleiten.

== Medium-Fragen

Die Medium-Fragen stellen ein moderates Anspruchsniveau dar und verlangen oft zusätzliche Einordnung. Nachfolgend die falsch beantworteten Beispiele und ihre Analyse.


==== _What is the category for sacrifice throws?_

- Expected: sutemi-waza  
- Span: _nage waza_ (Start: 9353, End: 9362)  
- Similarity Score: 57.74


#underline[Prüfung der Antwort:]
  
_nage waza_ (Wurftechniken im Allgemeinen) ist eine Oberkategorie, die _sutemi-waza_ (Würfe bei denen man auch selbst fällt) unter sich fasst, aber nicht identisch damit ist. Die Antwort ist deswegen unpräzise.


#underline[Mögliche Ursachen:]
  
1. Hierarchie-Verwechslung/ Generalisierung: Das Modell erkennt _waza_ im Kontext, wählt jedoch die bekanntere Oberkategorie _nage waza_. 
2. Verschiedene Häufigkeit im Text: Im Korpus taucht _sutemi waza_ 9 mal auf, _nage waza_ hingegen 22 mal, wodurch _nage waza_ als statistisch relevanter gilt.


#underline[Verbesserungsvorschläge:]
  
- Gezielte Fine-Tuning-Beispiele: QA-Paare, in denen zweimal hintereinander Unterkategorien abgefragt werden, damit das Modell den Unterschied lernt.  
- Semantische Constraints: Regeln implementieren, die verhindern, dass eine Oberkategorie akzeptiert wird, wenn eine spezifischere Unterkategorie gesucht ist.

==== _What influenced European and Russian judoka?_

- Expected: their strong wrestling traditions  
- Span: _traditional forms of combat_ (Start: 7039, End: 7066)  
- Similarity Score: 28.51


#underline[Prüfung der Antwort:]
  
_Traditional forms of combat_ eine etwas weniger präzise, aber durchaus plausible Antwort. Hier zeigt sich demnach nicht die Schwäche des QA-Modells sondern die der Evaluierungsmethodik mit Cosine-Similariy.

==== _Which American judoka is also an MMA fighter?_

- Expected: Ronda Rousey  
- Span: _Hidehiko Yoshida_ (Start: 133357, End: 133373)  
- Similarity Score: 29.70


#underline[Prüfung der Antwort:]
  
Hidehiko Yoshida ist ein japanischer Judoka, der auch MMA-Kämpfe bestritt, aber die Frage verlangt explizit nach einem US-Judoka. Ronda Rousey ist korrekt und kommt in Textkorpus 7 mal vor, Hidehiko Yoshida nur 2 mal. Daher ist die falsche Antwort wohl der nicht-deterministischen Natur von LLMs geschuldet. 


==== _Name a forbidden sacrifice throw in competition._

- Expected: Kani basami  
- Span: _Finger, toe and ankle locks_ (Start: 77790, End: 77817)  
- Similarity Score: 5.55


#underline[Prüfung der Antwort:]
  
_Finger, toe and ankle locks_ sind verboten im Judo, stimmen also thematisch, aber die Frage verlangt einen verbotenen *sacrifice throw*. Die Antwortmethode ist deswegen nicht vollständig falsch, aber inkonsequent zur Kategorie.


#underline[Mögliche Ursachen:]
  
- Kategorienverschachtelung: Das Modell hat erkannt, dass _locks_ verboten sind, aber nicht unterschieden, ob es sich um Hebel-, Würge- oder Wurftechniken handelt. Bei dieser Frage wird ähnlich wie bei der vorherigen eine Einschränkung ignoriert (z.B. dass es sich hier um sacrifice throws handeln soll).


#underline[Verbesserungsvorschläge:]
    
- Spezifische Schlüsselwörter: Frage um _sacrifice throw (sutemi waza)_ erweitern, damit das Modell sich auf Wurftechniken fokussiert.


#underline[Verbesserungsvorschläge:]
  
- Konsistente Quellenaufbereitung: Vor dem Training oder der Chunk-Selektion sicherstellen, dass jede Technik klar ihrer richtigen Unterkategorie zugeordnet ist.  


==== _Which Olympic Games marked judo’s competitive transformation?_

- Expected: 1964 Tokyo Olympics  
- Span: _Summer Olympic Games_ (Start: 230, End: 250)  
- Similarity Score: 50.80


#underline[Prüfung der Antwort:]
  
_Summer Olympic Games_ ist zu allgemein – Judo wurde erstmals 1964 in Tokio zum Medaillenwettbewerb. Die korrekte Antwort muss die spezielle Ausgabe _1964 Tokyo Olympics_ nennen.


#underline[Mögliche Ursachen:]
  
1. Unklare Abgrenzung der verschiednen Olympischen Spiele: Das Modell hat zwar den Olympischen Kontext erfasst, aber nicht die genaue Jahreszahl.  
2. Generalisierung: Bei Fragen nach _which Olympics_ tendiert das Modell dazu, auf den Oberbegriff _Summer Olympic Games_ zurückzugreifen, anstatt die Jahreszahl/Austragungsort auszuwählen. 


#underline[Verbesserungsvorschläge:]
  
- Konkretere Frage: _At which Olympic Games did judo become an official medal sport?_  

== Hard-Fragen

Hard-Fragen erfordern oft sehr spezifisches Fachwissen oder historische Details:

==== _What are the two guiding principles of judo?_

- Expected: Seiryoku-Zen’yō and Jita-Kyōei  
- Span: _life, art and science_ (Start: 79065, End: 79086)  
- Similarity Score: 15.01


#underline[Prüfung der Antwort:]
  
_Life, art and science_ beschreibt die Philosophie von Judo, aber nicht die beiden Kodokan-Leitsätze. Die Antwort ist daher nicht präzise.


#underline[Mögliche Ursachen:]
  
1. Konflikt philosophischer Passagen: Das Modell extrahiert allgemeine Philosophiebeschreibungen, wenn nach Prinzipien gefragt wird.  
2. Ungenaue Formulierung der Frage: _Guiding principles_ kann auch breit interpretiert werden, aber hier sind spezifische japanische Leitsätze gefordert.


#underline[Verbesserungsvorschläge:]
  
- Explizite Begriffsvorgabe: Frage als _What are the two Japanese guiding principles of the Kodokan?_ stellen.  

== Zusammenfassung der Verbesserungsansätze

1. Präzisere Frage-Formulierungen  
   - Zusätzliche Schlüsselwörter (z. B. _literal translation_, _in competition_, _in Europe_) helfen dem Modell, die Antwortspan-Auswahl zu fokussieren.

2. Semantische und regelbasierte Nachbearbeitung  
   - Filtersysteme für technische Begriffe, Personen-NER und numerische Werte.  
   - Post-Processing: Auswertung des Antwortspans, um Vollständigkeit und Kategoriezugehörigkeit zu prüfen.

3. Data Augmentation und Fine-Tuning  
   - Hinzufügen von QA-Beispielen, die häufige Fehlerfälle adressieren.  
   - Nutzung von kontrastiven Beispielen: Positiv- und Negativ-Beispiele einbinden (Few-Shot Learning).

4. Glossarerweiterung  
   - Aufbau eines Judo-Wörterbuchs mit Verweisen auf offizielle Begriffe (Techniken, Prinzipien, historische Daten). Das wäre ein strukturierterer Ansatz als der jetzige, wo unterschiedliche Texte einfach konkateniert werden.
   - Nutzung eines externen Knowledge Graphs, um die semantische Validität der extrahierten Antworten zu prüfen. So könnten auch klare Hierarchien zwischen Techniken definiert werden.

Aus den erwähnten Punkten folgt, dass Textkorpus, Frageformulierung und Evaluierungsmethodik alle noch Optimierungspotentiale haben, die das Test-Environment robuster machen können.

= Anwendungsfälle von QA-Systemen in der Praxis

In dieser Arbeit wurde der Fokus auf Extractive-Question-Answering-Systeme (QA) gelegt, die sowohl Faktenwissen als auch konzeptuelle Zusammenhänge extrahieren. Im Folgenden werden zentrale Einsatzfelder kurz skizziert.

QA-Systeme mit Fokus auf Fakten- und Konzeptwissen bieten in zahlreichen Domänen hohen Mehrwert. Sie beschleunigen Recherche, verbessern Informationszugang und unterstützen komplexe Entscheidungsprozesse. Zukünftige Fortschritte in semantischen Repräsentationen und multimodaler Integration werden die Einsatzmöglichkeiten weiter ausdehnen.

#show table.cell.where(y: 0): set text(weight: "light")
#table(
  columns: 1,
  stroke: (thickness: 0.25pt, paint: gray),
  fill: (col, row) => if 
    row == 0  or row == 2  or row == 4  or row == 6  or row == 8  or 
    row == 10 or row == 12 or row == 14 or row == 16 or row == 18 or 
    row == 20 { rgb("#f2f2f2") } else { none }, [
    Bildung & E-Learning
  ],
  [
    Interaktives Lernen liefert präzise Fakten und kontextuelle Erklärungen zu Lehrtexten. Lehrkraft-Unterstützung erstellt automatisch Quizfragen und erläutert komplexe Konzepte.
  ],
  [
    Customer Support & Helpdesk
  ],
  [
    Automatisierte FAQ-Bearbeitung extrahiert Produktfakten und Prozessabläufe aus Dokumentationen. Multimodale Fehlerdiagnose identifiziert Fehlermeldungen und erklärt dahinterstehende Konzepte.
  ],
  [
    Enterprise Knowledge Management
  ],
  [
    Dokumentenrecherche fördert schnelle Faktenfindung (z. B. Ansprechpartner, Fristen) und semantische Extraktion von Prozessabläufen. Compliance/Audit liefert zitierfähige Passagen und erklärt Risiken bei Nichteinhaltung.
  ],
  [
    Medizinische Informationssysteme
  ],
  [
    Patienten-Information beantwortet Dosierungsfragen und erklärt Krankheitszusammenhänge. Forschungsunterstützung extrahiert Studiendaten und konzeptuelle Hypothesen aus Publikationen.
  ],
  [
    Recht & Compliance
  ],
  [
    Juristische Recherche zitiert Gesetzesartikel und erläutert rechtliche Konzepte. Vertragsanalyse identifiziert wesentliche Klauseln und bewertet deren rechtliche Wirkung.
  ],
  [
    Wissenschaftliche Forschung & Literaturübersicht
  ],
  [
    Studienauswertung liefert Stichprobengrößen und konzeptuelle Limitationen aus Papers. Interdisziplinäre Recherchen erklären Methodenübertragungen und vergleichen Fachbegriffe.
  ],
  [
    Öffentliche Dienste & Behörden
  ],
  [
    Verwaltungsportale beantworten Unterlagenfragen und erläutern rechtliche Grundlagen. Krisenkommunikation liefert Notfallfakten und konzeptuelle Empfehlungen aus Leitfäden.
  ],
  [
    Digitale Bibliotheken & Archive
  ],
  [
    Historische Recherche findet Datumsfakten und bietet konzeptuelle Einordnungen zu Ereignissen. Multilinguale Dokumentenerschließung übersetzt Fragen und liefert Fakten sowie Konzepte aus fremdsprachigen Quellen.
  ],
)

= Fazit

Die Studienarbeit untersuchte systematisch die Leistungsfähigkeit von LLM-basierten Question-Answering-Systemen im Bereich faktischen Wissens. Basierend auf einem domänenspezifischen Korpus (Judo) und einem methodisch fundierten Test-Environment wurden folgende Kernaussagen validiert:

- *Begrenzte Faktenzuverlässigkeit*:  
  Selbst moderne LLMs zeigen signifikante Limitationen bei der Beantwortung faktischer Fragen. Die maximale Accuracy von 69,2 % (Voller Kontext) bestätigt frühere Studien wie @head-to-tail – LLMs sind keine universellen Wissensspeicher.

- *Kontextreduktion als Double-Edged Sword*:  
  Semantisches Chunking steigert die Effizienz (bis zu 68 % kürzere Kontexte), führt aber ab >50 % Reduktion zu drastischem Accuracy-Einbruch (≤50 %). Der Sweet Spot liegt bei ~75 % relevanter Chunks (23 % Zeichenreduktion, 62,8 % Accuracy).

- *Evaluierungsmetrik entscheidend*:  
  Herkömmliche String-Metriken (EM, F1) scheitern an semantischen Nuancen. SAS (Cosine Similarity ≥0.7) erwies sich als robuste Alternative zur Bewertung inhaltlicher Korrektheit.

- *Fehlerprofile zusammengefasst*:
  - *Easy-Fragen*: Fehler durch Generalisierung
  - *Medium/Hard-Fragen*: Kategorienverwechslungen und Kontextinkonsistenzen.
  - *Geschlossene Fragen*: (Ja/Nein) bereiten LLMs besondere Schwierigkeiten.

- *LoRA-Fine-Tuning ohne Breakthrough*:  
  In diesem Use Case brachte parameter-effizientes Fine-Tuning keinen Accuracy-Zuwachs – ein Hinweis auf inhärente Wissenslücken, nicht nur Domänenadaptionsbedarf.

= Ausblick

Basierend auf den Erkenntnissen ergeben sich folgende Forschungs- und Optimierungsperspektiven:

== Methodische Weiterentwicklungen

- *Adaptives Chunking*:  
  Dynamische Chunk-Auswahl basierend auf semantischer Score-Verteilung (z. B. Threshold ≥0.6) statt fixer Reduktionsraten.

- *Hybride Evaluierung*:  
  Kombination von SAS mit regelbasierten Filtern (z. B. Fachbegriffslexika) zur Reduktion von Fehlklassifikationen bei Synonymen. Dies ist auch durch die Angabe von mehreren Musterantworten pro Frage realisierbar.

- *Strukturierte Kontextanreicherung*:  
  Integration von Knowledge Graphs zur expliziten Modellierung von Begriffs-Hierarchien (z. B. _sutemi-waza ⊂ nage-waza_).

== Architekturinnovationen

- *Few-Shot Prompt Engineering*:  
  Kontrastive Beispiele (positiv und negativ) in Prompts, um das Modell auf präzise Begriffe oder die erwartete Antwort-Art zu konditionieren. 

- *Multimodale Erweiterung*:  
  Kombination von Text-QA mit visuellen Technik-Diagrammen würde weitere spannende Usecases ermöglichen.

Die Arbeit unterstreicht: LLM-basiertes QA ist ein leistungsfähiges, aber begrenztes Werkzeug. Seine Zuverlässigkeit hängt maßgeblich von präziser Fragenformulierung und einem passend zugeschnittenen Kontext ab – besonders bei faktisch kritischen Anwendungen.


= Bibliographie
#bibliography("zotero.bib", style: "american-psychological-association", title: none)

= Anhang

== Easy-Fragen
#table(
  columns: (2fr, 1fr),
  stroke: 0.5pt + gray.lighten(50%),
  table.header(
    [Frage], [Antwort],
  ),
  [What does judo mean?], [gentle way],
  [Who founded judo?], [Kanō Jigorō],
  [What is the name of the school Kanō Jigorō established?], [Kōdōkan],
  [What is the judo uniform called?], [jūdōgi],
  [What color belt do novices wear?], [white],
  [What color belt do masters wear?], [black],
  [What is the term for judo students?], [jūdōka],
  [What is the term for free practice in judo?], [randori],
  [What is the objective of judo?], [throw, pin, or submit opponent],
  [What does ippon mean?], [one point],
  [What does waza-ari mean?], [half point],
  [What is a minor point called?], [yuko],
  [What is the category for standing techniques?], [tachi-waza],
  [What is the category for ground techniques?], [ne-waza],
  [Who is the person performing the throw?], [tori],
  [Who is the person receiving the throw?], [uke],
  [Name a shime-waza technique.], [Nami-juji-jime],
  [Name a kansetsu-waza technique.], [Ude-garami],
  [Name an osaekomi-waza technique.], [Kesa-gatame],
  [What type of contact is judo?], [full contact],
  [Is judo mixed-sex?], [no],
  [What is the focus of judo?], [throwing],
  [What does judogi translate to?], [judo attire],
  [What does judoka mean?], [judo performer],
  [What does nage-waza include?], [throwing techniques],
  [What is the governing body of international judo?], [International Judo Federation],
  [What do judoka wear on their feet during practice?], [bare feet],
  [What is the traditional judo attire made of?], [strong white cloth],
)

== Medium-Fragen

#table(
  columns: (2fr, 1fr),
  stroke: 0.5pt + gray.lighten(50%),
  table.header(
    [Frage], [Antwort],
  ),
  [What is the term for pre-arranged forms in judo?], [kata],
  [From which martial art did judo originate?], [jujitsu],
  [What is the Japanese term for throwing techniques?], [nage-waza],
  [What is the category for sacrifice throws?], [sutemi-waza],
  [What is the category for hip throwing techniques?], [koshi-waza],
  [What is the category for foot throwing techniques?], [ashi-waza],
  [What is the maximum dan rank in judo?], [10th dan],
  [What is the symbol at the center of the Kodokan emblem?], [red circle],
  [What black belt rank is shodan?], [first rank],
  [Name a Kodokan kata.], [Ju-no-kata],
  [What does katame-waza include?], [grappling techniques],
  [What did Kano eliminate from his art?], [the most dangerous techniques],
  [What did Kano preserve in kata?], [classical techniques of jujitsu],
  [What influenced European and Russian judoka?], [their strong wrestling traditions],
  [What Russian art was based on judo?], [sambo],
  [Which American judoka is also an MMA fighter?], [Ronda Rousey],
  [How many national federations does the IJF bring together?], [more than 200],
  [How many continental unions does the IJF have?], [5],
  [Where is the International Judo Federation headquartered?], [Budapest, Hungary],
)

== Hard-Fragen

#table(
  columns: (2fr, 1fr),
  stroke: 0.5pt + gray.lighten(50%),
  table.header(
    [Frage], [Antwort],
  ),
  [In what year was judo founded?], [1882],
  [What is the Japanese term for grappling techniques?], [katame-waza],
  [What is the Japanese term for body-striking techniques?], [atemi-waza],
  [What is the Japanese term for blocks and parries?], [uke-waza],
  [What is the Japanese term for resuscitation techniques?], [kappo],
  [How many throws are in the Kodokan Gokyo-no-waza?], [67],
  [When did men's judo first appear at the Olympics?], [1964],
  [When did women's judo first appear at the Olympics?], [1992],
  [In what year did the first women's World Judo Championships take place?], [1980],
  [In what year did women's judo debut as a demonstration sport at the Olympics?], [1988],
  [What are the two guiding principles of judo?], [Seiryoku‑Zen'yō and Jita‑Kyōei],
  [What does Seiryoku‑Zen'yō mean?], [maximum efficient use of energy],
  [What does Jita‑Kyōei mean?], [mutual welfare and benefit],
  [In what year was the International Judo Federation founded?], [1951],
  [Who was the first president of the International Judo Federation?], [Aldo Torti],
  [Who succeeded Aldo Torti as IJF president?], [Risei Kano],
  [What shape is the Kodokan emblem?], [octagonal mirror],
  [Which two students received the first ever shodan ranks?], [Tsunejirō Tomita and Shiro Saigo],
  [Name a forbidden sacrifice throw in competition.], [Kani basami],
  [Name a prohibited katame-waza technique.], [Do-jime],
  [Name a non-Kodokan Japanese kata.], [Go-no-sen-no-kata],
  [In what year did Kano open a women's section at the Kodokan?], [1923],
  [Who dedicated her life to spreading women's judo?], [Keiko Fukuda],
  [In what year was the European Judo Union first created?], [1932],
  [Where were the first European Judo Championships held?], [Dresden],
  [What does uke-waza include?], [blocks and parries],
  [What does atemi-waza include?], [body-striking techniques],
  [What did Kano stress in practice?], [randori],
  [What English phrase describes ju yoku go o seisu?], [softness controls hardness],
  [What was judo’s inclusion status for the 1940 Tokyo Olympics?], [demonstration sport],
  [Which Olympic Games marked judo’s competitive transformation?], [1964 Tokyo Olympics],
)
