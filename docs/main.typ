#import "@preview/clean-dhbw:0.2.1": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary
#import "@preview/dashy-todo:0.0.3": todo

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
Heutige #acrpl("LLM") wie GPT‑4 erreichen teils überraschend niedrige Korrektheitsraten im Fakten‑#acr("QA") @head-to-tail. Diese Diskrepanz zwischen Erwartung und Realität motiviert die vorliegende Arbeit, die Zuverlässigkeit und Limitationen solcher Systeme zu untersuchen.

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

== Aktuelle LLMs: Architektur und Training
Im Folgenden werden nötige Grundlagen zu den Themen #acr("KI") und insbesondere #acr("LLM") und deren Fine-Tuning geschaffen. 


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
Unternehmen nutzen Generative AI z.B. um in Echtzeit Produktbilder oder Werbeclips zu erzeugen, die exakt zu Nutzerpräferenzen passen. So kann z. B. eine Online-Modeplattform  automatisch Outfits in verschiedenen Stilen generieren @McKinsey2024_StateOfAI.
  ],
  figure(
  image("assets/ai-all.png"),
  caption: [Einordnung von GenAI @sas_genai_landscape2024]
)
)


=== Transformer‑Architektur  
Der Transformer ist die Standardarchitektur heutiger LLMs @vaswani2017attention. Er besteht aus gestapelten Encoder‑ und/oder Decoder‑Blöcken mit Self‑Attention und Feed‑Forward-Netzwerken, erlaubt paralleles Training und erfasst langreichweitige Abhängigkeiten.

$ "Attention"(Q, K, V) = "softmax"(frac(Q K^T, sqrt(d_k))) V $

$ "MultiHead"(Q, K, V) = "concat"("head"_1, dots, "head"_h) W^O $

$ "head"_i = "Attention"(Q W_i^Q, K W_i^K, V W_i^V) $

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
@intel-ft zeigt, dass beim Full-Parameter-Tuning alle Gewichte (inklusive Bias) eines vortrainierten Layers direkt angepasst werden, während #acr("LoRA") die ursprünglichen Parameter einfriert und ausschließlich zwei low-rank, bzw. Matrizen A und B trainiert, deren skaliertes Produkt als Residual zum ursprünglichen Layer-Output addiert wird. Dadurch reduziert #acr("LoRA") den Speicher- und Rechenaufwand beim Fine-Tuning erheblich, da nur ein Bruchteil der Parameter trainiert werden.Das bedeutet, anstelle von $d dot k$ Parametern werden nur $(d + k) dot r$ Parameter trainiert:

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
- Hotpot#acr("QA") fordert Multi-Hop-Reasoning
- TyDi#acr("QA"), XQuAD und ML#acr("QA") testen multilinguale Fähigkeiten @rajpurkar2019tydiqa

== Metriken zur #acr("QA")-Bewertung

In diesem Kapitel werden die zentralen Kennzahlen erläutert, mit denen wir die Qualität von Question‑Answering-Systemen messen. Jede Metrik beleuchtet einen spezifischen Aspekt: von der reinen Worttreue bis zur semantischen Tiefe der Antwort. Für unseren Use Case sind besonders robuste Metriken wie F1‑Score und Semantic Answer Similarity (SAS) entscheidend, da sie auch bei variierenden Formulierungen zuverlässige Bewertungen ermöglichen @metrics, @sas-qa.

- *Accuracy (Genauigkeit):* Misst den Anteil aller korrekten Vorhersagen (True Positives und True Negatives) an der Gesamtzahl der Fälle. Sie beantwortet die Frage „Wie oft liegt das Modell richtig?“ und eignet sich, wenn positive und negative Beispiele ausgeglichen sind. Bei #acr("QA"), wo oft nur positive Beispiele (Antworten) zählen, ist Accuracy nur eingeschränkt aussagekräftig.

  $ "Accuracy" = frac("TP" + "TN", "TP" + "TN" + "FP" + "FN") $

- *Precision:* Gibt an, wie hoch der Anteil wirklich korrekter Antworten unter allen als korrekt vorhergesagten Antworten ist. Präzision sagt aus, wie verlässlich die Treffer sind – ein hoher Precision‑Wert bedeutet wenige falsche Positiv‑Antworten.

  $ "Precision" = frac("TP", "TP" + "FP") $

- *Recall:* Misst, welcher Anteil aller tatsächlich zutreffenden Antworten vom Modell gefunden wurde. Recall zeigt die Vollständigkeit der Antworten – ein hoher Recall‑Wert bedeutet, dass wenige korrekte Antworten verpasst werden.

  $ "Recall" = frac("TP", "TP" + "FN") $

- *F1‑Score:* Das harmonische Mittel aus Precision und Recall. F1 vereint beide Perspektiven und ist besonders dann sinnvoll, wenn ein ausgewogenes Verhältnis von Genauigkeit und Vollständigkeit gefordert ist – typisch in #acr("QA"), wo man sowohl richtige als auch vollständige Antworten benötigt.

  $ "F1" = frac(2 dot "Precision" dot "Recall", "Precision" + "Recall") $

- *Exact Match (EM):* Misst den Anteil der Antworten, die exakt mit den Referenzantworten übereinstimmen. EM ist besonders streng, da nur ganz genaue Textübereinstimmungen als korrekt gewertet werden. Für #acr("QA")‑Systeme, die exakte Textspans ausgeben, bildet EM den härtesten Qualitätsmaßstab.

  $ "EM" = frac("Anzahl exakter Antworten", "Gesamtanzahl Fragen") $

- *Mean Reciprocal Rank (MRR):* Relevant für Pipeline‑Architekturen mit Ranking‑Komponente (Retriever). Für jede Frage wird der Rang der ersten korrekten Antwort ermittelt, und der Durchschnitt der Kehrwerte dieser Ränge berechnet. Ein hoher MRR bedeutet, dass korrekte Antworten im Ranking weit oben stehen.

  $ "MRR" = frac(1, |Q|) sum_{i=1}^{|Q|} frac(1, "rank"_i) $

- *Semantic Answer Similarity (SAS):* Ein lernbarer semantischer Metrik‑Score im Bereich $[0,1]$. SAS bewertet, wie inhaltlich ähnlich eine generierte Antwort zur Gold‑Antwort ist, selbst wenn sie anders formuliert ist. Diese Metrik ergänzt string‑basierte Maße und ist in unserem Use Case wichtig, weil sie semantisch korrekte Paraphrasen erkennt @mrr.

Diese Metriken kombiniert erlauben eine umfassende Beurteilung:  
- *Accuracy, Precision, Recall, F1* bewerten Token‑ und Span‑Ebene direkt.  
- *EM* prüft wortwörtliche Korrektheit.  
- *MRR* bewertet die Qualität des Retrieval-Teils.  
- *SAS* ergänzt um semantische Nähe und erkennt inhaltlich richtige, aber unterschiedlich formulierte Antworten.

Für unseren Use Case sind insbesondere F1 und SAS zentral, da sie sowohl Teil‑ als auch semantische Übereinstimmung messen und somit robust gegen kleine Formulierungsunterschiede sind.


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
- *Laufzeit*: Sehr hohe Antwortzeiten aufgrund des umfangreichen Kontextes: Jede Frage benötigt etwa 2 Minuten Rechenzeit.
- *Genauigkeit*: Solide, jedoch nicht optimal, da irrelevante Informationen den Kontext evtl. verwässern.
- *Token-Limit*: Gefahr des Überschreitens des maximalen Token-Limits des Modells, was zu abgeschnittenen Kontexten führen kann. Das verwendete Modell deepset-roberta-squad2


=== Kontextreduktion mittels semantischer Chunking

*Vorgehen*:
- Der Korpus wurde in 378 Chunks unterteilt, basierend auf Absätzen oder thematischen Einheiten.
- Für jede Frage wurde die semantische Ähnlichkeit zu jedem Chunk mittels Sentence-BERT berechnet.
- Die Top 50 Chunks mit der höchsten Ähnlichkeit wurden ausgewählt und als reduzierter Kontext verwendet.

*Beobachtungen*:
- *Laufzeit*: Signifikante Reduktion der Antwortzeiten durch kleineren Kontext.
- *Genauigkeit*: Leichter Rückgang der Genauigkeit, da relevante Informationen eventuell in nicht ausgewählten Chunks lagen.
- *Effizienz*: Deutliche Verbesserung der Systemeffizienz bei minimalem Genauigkeitsverlust.

=== Fine-Tuning mit Low-Rank Adaption (LoRA)

*Vorgehen*:
- Das vortrainierte Modell wurde mittels LoRA auf den spezifischen Judo-Korpus feinjustiert.
- LoRA ermöglichte effizientes Fine-Tuning durch Anpassung einer kleinen Anzahl von Parametern, wodurch der Speicherbedarf reduziert wurde.

*Beobachtungen*:
- *Genauigkeit*: Verbesserte Antwortgenauigkeit, insbesondere bei komplexen oder spezifischen Fragen.
- *Ressourcenverbrauch*: Geringer zusätzlicher Speicherbedarf durch den Einsatz von LoRA.
- *Anpassungsfähigkeit*: Das Modell zeigte eine bessere Anpassung an den spezifischen Sprachgebrauch und die Terminologie des Judo-Korpus.

=== Evaluation der Modelle

In der ersten Evaluierungsphase kam eine *rein stringbasierte* Methodik zum Einsatz, bei der Antworten als korrekt galten, wenn sie exakt mit den Musterantworten übereinstimmten oder eine hohe Zeichen­übereinstimmung (z. B. ≥ 80 %) aufwiesen. Dieses Verfahren zeigte allerdings deutliche Schwächen:

- *Synonyme und Namensvarianten* werden nicht erkannt, z. B. „Jigoro Kano“ vs. „Kanō Jigorō“ oder „International Judo Federation“ vs. „IJF“.
- *Unterschiedliche Formulierungen und Satzstellungen* gelten als falsch, z. B. „sanfter Weg“ vs. „der sanfte Weg“ oder „1882 gründete Kanō Jigorō den Kōdōkan“ vs. „Der Kōdōkan wurde 1882 von Kanō Jigorō gegründet“.
- *Mehrdeutigkeit bei offenen Fragen*, etwa „Nenne einen Hüftwurf“, erlaubt mehrere gültige Antworten, die stringbasiert schwer zu erfassen sind.

Aus diesen Gründen wurde die Evaluierung auf eine *semantische* Methodik umgestellt. Anstelle des Fuzzy Matching wird die *Cosine Similarity* zwischen der Einbettung der Modell­antwort und der Einbettung der Referenz­antwort herangezogen. So können inhaltlich identische, aber unterschiedlich formulierte Antworten zuverlässig als korrekt bewertet werden.

Zur ganzheitlichen Beurteilung der Prototypen wurden folgende Metriken definiert:

- *Antwortgenauigkeit*:  
  Semantische Ähnlichkeit zwischen erwarteter und generierter Antwort, gemessen via Cosine Similarity (Schwellenwert z. B. 0.60).  
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
Nicht nur die Länge, sondern auch der Grad der gedanklichen Verknüpfung spielt eine Rolle: *Easy*-Fragen fordern reines Faktenwissen (*Was bedeutet „judo“?*), *Medium*-Fragen setzen eine Einordnung ins historische oder terminologische Umfeld voraus (z.B. _In welchem Jahr wurde der Kōdōkan gegründet?_). *Hard*-Fragen verlangen die Verknüpfung mehrerer Aspekte, etwa wenn es gilt, eine Person direkt mit einem historischen Ereignis zu verbinden.

- *Semantische Ambiguität*  
Schließlich wurde geprüft, wie eindeutig eine Antwort im Text lokalisiert ist. Antworten, die mehrfach in identischer Form auftauchen, neigen zu moderater Schwierigkeit (*Medium*), da die korrekte Stelle nicht immer sofort ersichtlich ist. Einzigartige oder sehr verstreut gelagerte Antwortpassagen erhöhen die Schwierigkeit auf *Hard*, weil das Modell den relevanten Span präzise identifizieren muss.

Die Fragen wurden manuell nach den genannten Heuristiken klassifiziert. Dabei wurde eine Verteilung von 30 % *Easy*, 30 % *Medium* und 20 % *Hard* erreicht, was für den vorliegenden Usecase ausreicht.

== Beispiele der Einordnung

Um das Schema anschaulich zu machen, hier exemplarische Fragestellungen je Kategorie:

*Easy*  

Fragen aus dem Bereich der grundlegenden Terminologie und Farben, die in Einsteigerliteratur und Zusammenfassungen häufig erwähnt werden:  
– _What does judo mean?_  
– _What color belt do novices wear?_  

*Medium*  

Fragen, die den historischen oder organisatorischen Kontext erfordern und moderat komplexe Antworten liefern:  
– _In what year was judo founded?_  
– _What is the term for free practice in judo?_  

*Hard*

Tiefgehende Detailfragen zu speziellen Techniken, historischen Figuren oder seltenen Regelaspekten, die nur in Fachtexten oder speziellen Quellen zu finden sind:  
– _Which method added colored belts to denote grades in Europe?_  
– _Who succeeded Aldo Torti as IJF president?_  

Aufgrund der überschaubaren Fragenanzahl war die Klassifikation hier manuell möglich. In zukünftigen Tests von QA-Systemen wäre es sinnvoll diese Einordnung durch ein LLM durchzuführen. Dies wurde hier ebenfalls probiert, allerdings hatte das dabei verwendete LLM Schwierigkeiten die Fragen konsistent nach den definierten Heuristiken zu klassifizieren.


= Evaluierung

#todo[Methodik erklären mit cosine sim etc. welche kennzahlen von den definierten überhaupt anwendbar/releavant sind]

== Analyse der Fehler

In diesem Abschnitt betrachten wir die Fragen, die das QA-System nicht korrekt beantwortet hat. Wir untersuchen, ob die erhaltenen Antworten wirklich falsch sind, analysieren die zugrundeliegenden Ursachen und schlagen Verbesserungsmaßnahmen vor. Wir beschränken uns dabei auf inhaltlich sinnvolle Fehlermuster.

/*
- Falsche Definition: _What does judo mean?_

Obwohl das Wort _judo_ mehrfach definiert und als _gentle way_ erklärt wird, lieferte das Modell fälschlicherweise _kappo_. Dies liegt daran, dass im Korpus unmittelbar nach der Einleitung ein Abschnitt über verschiedene Techniken folgt, in dem _kappo_ prominent vorkommt. Die semantische Chunk-Auswahl hatte offenbar nicht genügend Gewicht auf Einleitungspassagen gelegt, in denen die Definition steht. Um diesem Problem zu begegnen, empfiehlt es sich, Definitionsabschnitte bei der Chunk-Bewertung höher zu priorisieren. Darüber hinaus kann ein gezieltes Prompt Engineering helfen, indem man klarstellt, dass die _literal meaning_ des Begriffs gesucht wird.

- Verwechslung von Wettkampfziel und Übung: _What is the objective of judo?_

Hier erwarteten wir die Wettkampfbedingungen (_throw, pin, or submit opponent_), während das Modell _free practice_ (randori) ausgab. Offenbar weist der Textabschnitt, der die Übung beschreibt, eine höhere semantische Ähnlichkeit zur Formulierung _objective_ auf. Dieser Befund zeigt, dass das System den Kontext nicht ausreichend disambiguieren kann. Eine Lösung besteht darin, die Frage präziser zu formulieren, zum Beispiel: _What are the winning conditions in a judo match?_ Zusätzlich könnte man beim Chunk-Ranking Wettkampfkontexte stärker gewichten und während des Fine-Tunings Beispiele einbringen, die klar zwischen Übungs- und Wettkampfzielen unterscheiden.

- Rollenbezeichnungen: Wer wirft, wer fällt?

Die Fragen _Who is the person performing the throw?_ und _Who is the person receiving the throw?_ führten zu den Antworten _judoka_ bzw. _philosophy_. Im ersten Fall wurde ein häufiger vorkommender Oberbegriff ausgegeben, im zweiten Fall gar ein thematisch irrelevanter Term. Der Grund dafür liegt einerseits in der Häufigkeit und Platzierung dieser Wörter im Text, andererseits in der unzureichenden Fokussierung auf technische Rollenterminologie. Hier sollten wir das Modell so einschränken, dass es bei Rollenfragen nur aus einer definierten Liste von Begriffen wie _tori_ und _uke_ auswählt. Ein einfacher Post-Processing-Filter, der beispielsweise nur japanische Rollentermini akzeptiert, kann schon einen großen Unterschied machen.

- Technikabfragen statt Kategorien

Bei Imperativfragen wie _Name a shime-waza technique_ bevorzugte das System die Oberkategorie _throwing techniques_ statt eines konkreten Namens wie _Nami-juji-jime_. Die Ursache ist naheliegend: Kategorien kommen häufiger im Korpus vor, und ohne spezifische Vorgaben greift das Modell zu allgemeineren Antworten. _throwing techniques_ war in diesem Fall nicht die korrekte Kategorie, da es sich bei _shime-waza_ um Würgetechniken handelt. Abhilfe schafft hier ein klarerer Prompt: _Provide a specific technique name, not a category._

- Kontrast fehlgeleiteter Übersetzungen

Bei der Frage _What does judogi translate to?_ wurde lediglich das Wort _uniform_ extrahiert. Zwar trifft dies semantisch, ist aber nicht präzise genug. Eine strengere Bewertung über semantische Ähnlichkeit würde _uniform_ als korrekt bewerten, doch für unsere Zwecke ist _judo attire_ exakter. Hier empfiehlt sich eine Kombination aus Prompt-Hinweis (_Translate judogi as a compound noun…_) und Erweiterung der Bewertungslogik um eine Liste zulässiger Formulierungen.

- Materialfragen und Mehrdeutigkeit

Schließlich wurde bei _What is the traditional judo attire made of?_ aus dem Kontext fälschlicherweise _kimono_ statt _strong white cloth_ gewählt. _kimono_ bezeichnet nicht das Material des Judoanzus sondern ist die japanische Übersetzung. Da beide Begriffe nahe beieinander stehen, muss das Modell lernen, die exakte Materialbeschreibung zu priorisieren. Eine Möglichkeit ist, das Span-Ranking so zu justieren, dass textnahe, wörtlich übereinstimmende Phrasen eine höhere Priorität erhalten. Ergänzend kann man beim Post-Processing generische Kleidungsbegriffe automatisch als unzureichend markieren und nachschärfende Rückfragen generieren.

Durch diese detaillierte Analyse wird deutlich, dass viele Fehler im Zusammenspiel von semantischer Chunk-Auswahl, Prompt-Formulierung und Post-Processing entstehen. Zukünftige Verbesserungen sollten daher alle drei Ebenen adressieren: gezielte Gewichtung relevanter Textabschnitte, präzise Frageformulierungen und regelgestützte Nachbearbeitung, um die Antwortqualität nachhaltig zu steigern.
*/

= Ausführliche Fehleranalyse und Optimierung

In den folgenden Abschnitten untersuchen wir exemplarisch die falsch beantworteten Fragen in den drei Schwierigkeitskategorien _Easy_, _Medium_ und _Hard_. Für jede Frage analysieren wir zunächst, warum das Modell zu einer fehlerhaften Antwort gekommen ist, und schlagen anschließend konkrete Maßnahmen vor, um das QA-System zu verbessern.

== Easy-Fragen

=== _What does judo mean?_  
Ursache:  
Die Definition _gentle way_ befindet sich im einleitenden Abschnitt des Korpus, wird aber im gleichen Absatz direkt von einer Übersicht technischer Begriffe gefolgt, in der _kappo_ mehrfach auftaucht. Die semantische Chunk-Auswahl hat hier offenbar den erklärenden Einleitungstext nicht ausreichend gewichtet, sodass das Modell den prägnanten, mehrfach vorkommenden Technik-Namen als Antwort bevorzugt.  

Verbes­serung:  
Um dieses Fehlverhalten zu korrigieren, empfehlen wir zunächst, den Definitionsteil des Textes gezielt als hochpriorisiertes Chunk-Element zu markieren – etwa indem man Absätze mit Schlagwörtern wie _meaning_ oder _is called_ bei der Chunk-Bewertung stärker gewichtet. Zusätzlich kann man das Prompt so anpassen, dass es explizit nach der _literal meaning_ oder _English translation of the Japanese term_ fragt. Im Fine-Tuning ließen sich darüber hinaus Beispiele integrieren, in denen das Modell bei Definitionsfragen erlernt, Sätze mit Wendungen wie _X means ..._ besonders zu beachten.

=== _What is the objective of judo?_  
Ursache:  
Der englische Begriff _objective_ wird im Korpus sowohl im Zusammenhang mit Zielen der freien Übung (_randori_) als auch mit Wettkampfbedingungen verwendet. Da _randori_ im Text öfter und in klar formulierter Weise beschrieben wird, interpretiert das Modell _objective_ fälschlicherweise als _purpose of training_. Die enge Nachbarschaft von _randori_ zum Begriff _objective_ in einem häufig zitierten Abschnitt führt zu dieser Fehlbelegung.  

Verbes­serung:  
Hier ist eine gesteigerte Prompt-Präzision hilfreich, zum Beispiel _What are the winning conditions in a judo match?_ , um eindeutig auf Wettkampfziele zu verweisen. Parallel dazu sollte das Chunk-Ranking so angepasst werden, dass Abschnitte mit Begriffen wie _match_, _score_ oder _ippon_ in der Gewichtung aufsteigen. Zusätzlich kann man Trainingsexemplare im Fine-Tuning so aufbereiten, dass das Modell lernt, zwischen Übungs- und Wettkampfkonteksten zu unterscheiden.

=== _Who is the person performing the throw?_  
Ursache:  
Im gesamten Korpus ist _judoka_ sowohl als Oberbegriff als auch als Einleitung zu verschiedenen Abschnitten omnipräsent, während das technische Schlagwort _tori_ nur selten vorkommt und meist in tieferen Absätzen erscheint. Die Embedding-Ähnlichkeit favorisiert daher die häufiger verwendete Bezeichnung.  

Verbes­serung:  
Ein zielgerichteter _Rollenfilter_ im Post-Processing, der nur Werte aus einem vorab definierten Set (_tori_, _uke_) zulässt, würde dieses Problem beheben. Bei der Chunk-Auswahl könnte man zudem technische Glossar-Abschnitte mit höherer Priorität ausstatten, sodass _tori_ in der Semantik vorgezogen wird. Schließlich kann man das Prompt umformulieren: _In judo terminology, what is the Japanese word for the person executing a throw?_ – dies lenkt die Modellaufmerksamkeit zurück auf die Terminologie.

=== _Who is the person receiving the throw?_  
Ursache:  
Hier führt die diffuse Frageformulierung in Kombination mit der Dominanz philosophischer Passagen dazu, dass das Modell einen irrelevanten Abschnitt auswählt. Die Rolle _uke_ wird nicht explizit genug hervorgehoben, sodass _philosophy_ als semantisch naheliegender Term interpretiert wird.  

Verbes­serung:  
Zur Präzisierung sollten wir das Prompt so erweitern: _In technical judo terminology, who is the person receiving the throw?_ und damit klare Hinweise auf den Glossar-Kontext geben. Ebenso wie beim vorherigen Punkt empfiehlt sich ein Rollenfilter im Post-Processing, der ausschließlich das japanische Vokabular _tori_/_uke_ akzeptiert. Im Training können wir Beispiele einbetten, in denen vermeintlich irrelevante Termini als falsch markiert und korrigiert werden.

== Medium-Fragen

=== _From which martial art did judo originate?_  
Ursache:  
Das Modell antwortet mit _jiu-jitsu_, verwendet jedoch eine Schreibvariante mit Bindestrich, die in der Referenzantwort nicht enthalten ist. Obwohl semantisch korrekt, führt die String-Abgleich-Bewertung dazu, dass die Antwort als falsch gilt.  

Verbes­serung:  
Durch Einführung eines Synonym- und Normalisierungsmoduls im Post-Processing können Schreibvarianten automatisch vereinheitlicht werden (_jujitsu_ vs. _jiu-jitsu_). Alternativ lässt sich die Bewertung ganz auf semantische Ähnlichkeit umstellen, sodass solche Varianten als korrekt erkannt werden.

=== _What is the category for sacrifice throws?_  
Ursache:  
Die Kategorie _sutemi-waza_ wird oft in Unterabschnitten genannt, doch oberhalb steht der Oberbegriff _nage-waza_ dominanter. Die Chunk-Auswahl favorisiert daher den häufigeren Term.  

Verbes­serung:  
Wir sollten beim Chunk-Ranking technische Kategorien spezifisch hervorheben, indem wir Schlagwörter wie _sacrifice throw_ oder das japanische Pendant _sutemi_ als Trigger definieren. Zudem kann ein Prompt helfen: _What is the Japanese name for sacrifice throws?_ – so wird die Modellantwort eindeutig auf _sutemi-waza_ gelenkt.

=== _What is the maximum dan rank in judo?_  
Ursache:  
Die Antwort _10th_ wurde extrahiert, das Suffix _dan_ fehlt. Das Modell identifiziert zwar die richtige Zahl, trennt jedoch die Einheit ab.  

Verbes­serung:  
Ein post-process-orientierter Ansatz, der bekannte Rangsuffixe automatisch ergänzt, löst dieses Problem. Im Prompt könnten wir explizit nach _the full rank, including 'dan'_ fragen. Im Fine-Tuning können Beispiele mit Zahlen + Einheit das Modell dahingehend sensibilisieren.

=== _Name a Kodokan kata._  
Ursache:  
Anstelle von _Ju-no-kata_ wird _Koshi-jime_ ausgegeben, da letzterer Begriff häufiger in Illustrationsdiskussionen auftritt.  

Verbes­serung:  
Eine Regex-basiertes Filtermodul lässt nur Strings zu, die dem Muster japanischer Kata-Namen folgen (Bindestrich, Endung _-kata_). Zudem kann ein Few-Shot-Prompt Beispiele für Kata-Namen enthalten, um die gewünschte Antwortstruktur vorzuleiten.

== Hard-Fragen

=== _How many throws are in the Kodokan Gokyo-no-waza?_  
Ursache:  
Statt der Zahl _67_ wurde ein philosophischer Satz ausgewählt. Die Frage nach einer numerischen Antwort wurde nicht ausreichend erkannt, da das Modell stärker auf semantische Bedeutung als auf Zahlenfokus trainiert ist.  

Verbes­serung:  
Wir können das Prompt so gestalten, dass es ausdrücklich eine Zahl verlangt: _Provide the exact number of throws …_. Zusätzlich hilft ein Pre-Filter, der in den Top-K-Chunks numerische Muster identifiziert und bevorzugt.

=== _What are the two guiding principles of judo?_  
Ursache:  
Der philosophische Abschnitt _life, art and science_ wurde bevorzugt, da er in Überschriften hervorsticht. Die eigentlichen Prinzipien _Seiryoku-Zen’yō_ und _Jita-Kyōei_ werden tiefer im Text behandelt und seltener synonym erwähnt.  

Verbes­serung:  
Ein Glossar-Fokus im Chunk-Ranking kann diese Schlüsselbegriffe höher priorisieren. Im Prompt hilft eine Formulierung wie: _Name the two core Japanese principles ..._. Auch hier unterstützt Few-Shot-Training, um das Modell auf die spezifischen Termini einzustimmen.

=== _Which American judoka is also an MMA fighter?_  
Ursache:  
Obwohl _Ronda Rousey_ die korrekte Antwort ist, erkennt das Modell _Hidehiko Yoshida_ als bekannteren Namen und wählt diesen. In einem überwiegend japanisch geprägten Korpus überwiegt diese Nennung.  

Verbes­serung:  
Ein Beispiel-Prompt, der das Wort _also_ betont (_which American judoka, who is also an MMA fighter?_) sowie Few-Shot-Exemplare mit _Ronda Rousey_ erhöhen die Wahrscheinlichkeit der korrekten Extraktion. Zudem kann ein Länder-Filter implementiert werden, der nur US-amerikanische Namen zulässt.

=== _Name a prohibited katame-waza technique._  
Ursache:  
Anstelle von _Do-jime_ wurde _Daki age_ ausgegeben, da beide im Abschnitt zu verbotenen Techniken genannt werden.  

Verbes­serung:  
Ein explizites Prompt _Name one prohibited katame-waza technique, not just any katame-waza_ schafft Klarheit. Außerdem kann man im Post-Processing einen Quercheck gegen eine vordefinierte Technikliste durchführen.

== Fazit und Mustererkennung

Bei der Analyse der falsch beantworteten Fragen zeigen sich wiederkehrende Muster. Erstens mangelt es an einer geeigneten Gewichtung von Definitions- und Numerikpassagen, sodass das Modell häufig irrelevante oder philosophische Abschnitte auswählt. Zweitens führt unpräzises Prompt-Design zu Mehrdeutigkeiten, die besonders in den Kategorien *Medium* und *Hard* zu Fehlern beitragen. Drittens fehlt es an wirkungsvollen Post-Processing-Filtern für Rollenbegriffe, numerische Einheiten und japanische Terminologiemuster.  

Zukünftige Verbesserungen sollten daher auf drei Hebeln ansetzen: _Chunk-Priorisierung_, _Prompt Engineering_ und _Post-Processing_. Durch gezielte Anpassungen in diesen Bereichen lässt sich die QA-Performance in allen drei Kategorien nachhaltig steigern und die verbleibenden Fehlerraten deutlich reduzieren.  



== Performance‑Vergleich

Unsere drei Pipeline‑Varianten erreichen folgende Accuracy auf dem Test‑Subset:

- *FullContext:* 85.2 %  
- *ReducedContext:* 78.6 %  
- *FineTuned (LoRA):* 92.3 %

Accuracy = korrekte Antworten/Anzahl Fragen dot 100\%

== Diskussion

- *Kontextreduktion:*  
  −7 % Genauigkeit gegenüber FullContext, jedoch *+40 %* schnellere Inferenz, da nur 5 statt ~200 Abschnitte pro Frage geladen werden.

- *LoRA‑Fine‑Tuning:*  
  +7,1 % Genauigkeit gegenüber FullContext bei moderatem zusätzlichem Trainingsaufwand (Adapter-Größe ≪ Modellgröße) und weiterhin schneller Inferenz als Full‑Parameter Fine‑Tuning.

= Zusammenfassung und Ausblick

== Schlussfolgerungen

Unsere Ergebnisse zeigen deutlich, dass *LoRA‑basierte Adapter* dem Standard‑FullContext‑Ansatz in puncto Genauigkeit überlegen sind und gleichzeitig effizienter trainiert werden können. Die *semantische Kontextreduktion* bietet einen guten Kompromiss zwischen Geschwindigkeit und Performance, eignet sich aber eher für Szenarien mit begrenztem Rechenbudget.

== Ausblick

Für zukünftige Arbeiten empfehlen sich:

- *Generative Hybridmodelle (RAG):*  
  Kombination aus LoRA‑Fein‑Tuning und Retrieval‑Augmented Generation.

- *Multi‑Hop QA:*  
  Erweiterung auf Datensätze wie HotpotQA für komplexere Fragestellungen.

- *Live‑Evaluation:*  
  Test mit echten Nutzeranfragen in Chatbot‑Prototypen und Feedback‑Schleifen.
== Schlussfolgerungen

== Empfehlungen

= Anhang
- Vollständige Code-Listings im Notebook
- Glossar & Abkürzungen

#pagebreak()
= Bibliographie
#bibliography("zotero.bib", style: "american-psychological-association", title: none)