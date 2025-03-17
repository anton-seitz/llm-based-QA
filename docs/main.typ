#let acronyms = (
  API: "Application Programming Interface",
  HTTP: "Hypertext Transfer Protocol",
  REST: "Representational State Transfer",
  QA: "Question Answering",
  LLM: "Large Language Model",
  NLP: "Natural Language Processing",
  GPU: "Graphics Processing Unit"
)

#import "@preview/clean-dhbw:0.2.1": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#show: clean-dhbw.with(
  // Titel & Art der Arbeit
  title: "Evaluierung von LLM-basiertem QA",
  type-of-thesis: "Studienarbeit",
  authors: (
    (
      name: "Anton Seitz",
      student-id: "0000000",
      course: "INF22B",
      course-of-studies: "Informatik"
    ),
  ),
  at-university: true,
  city: "Stuttgart",

  // Kurze Zusammenfassung (Abstract)
  abstract: "Diese Arbeit untersucht systematisch die Antwortqualität von LLM-basierten QA-Systemen. Aufbauend auf den Erkenntnissen aus [1] und [2] wird ein neues Test-Environment entwickelt, in dem ein speziell definierter Textkorpus – beispielsweise aus judo-spezifischen Quellen und Wikipedia-Artikeln – sowie gezielte Variationen der Fragestellungen zur Evaluation herangezogen werden. Ziel ist es, mittels quantitativer Metriken (z. B. Genauigkeit, Präzision, Recall, F1-Score) und qualitativer Analysen die Leistungsfähigkeit der #acrplLLM hinsichtlich Korrektheit und Vollständigkeit der generierten Antworten zu bewerten. Die gewonnenen Erkenntnisse sollen die aktuellen Grenzen der Modelle aufzeigen und Ansatzpunkte für deren Optimierung in praktischen Anwendungen liefern.",
  
  // Bib-Datei
  bibliography: bibliography("sources.bib"),
  // Datum, Sprache und Glossar/Acronyme
  date: datetime.today(),
  glossary: glossary,
  acronyms: acronyms,
  language: "de",

  // Betreuer, Hochschule
  supervisor: (university: "Dr. Armin Roth"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Stuttgart",
  university-short: "DHBW"
)

= Kurzbeschreibung der Arbeit

Diese Studienarbeit befasst sich mit der Evaluierung von #acr("LLM")-basiertem #acr("QA"). Dabei wird untersucht, wie #acrpl("LLM") in der Lage sind, natürlich formulierte Fragen basierend auf einem definierten Textkorpus automatisch zu beantworten. Der Textkorpus wird aus fachspezifischen Quellen (z. B. judo-spezifische Literatur, Wettkampfdaten) und ergänzend aus öffentlich zugänglichen Daten wie Wikipedia-Artikeln zusammengestellt. Die Ausgangssituation ist geprägt durch den rasanten Fortschritt im Bereich der künstlichen Intelligenz und #acr("NLP"). Trotz der beeindruckenden Leistungsfähigkeit weisen aktuelle Modelle oftmals Defizite in Bezug auf Faktenwissen und Detailgenauigkeit auf. Ziel dieser Arbeit ist es, die Antwortqualität – gemessen an Kriterien wie Korrektheit, Vollständigkeit und Relevanz – systematisch zu bewerten und potenzielle Einsatzbereiche, beispielsweise im Kundensupport oder internen Wissensmanagement, zu identifizieren.

= Einleitung

Dieses Kapitel führt in das Themengebiet ein und legt die Motivation sowie die Problemstellung dar.
== Motivation
Führende #acrpl("LLM") werden im Zuge des aktuellen Hypes häufig als Alleskönner dargestellt. Wie in @head-to-tail ersichtlich, weisen diese Modelle jedoch oftmals ein mangelhaftes Faktenwissen auf und beantworten selbst bei bekannten Informationen natürlichsprachliche Fragen fehlerhaft. Sogar das beste getestete Modell, GPT-4, erreichte lediglich eine Korrektheitsrate von 40,3 %. Diese Diskrepanz zwischen den Erwartungen und der tatsächlichen Leistungsfähigkeit bildet die Motivation für diese Arbeit. Ziel ist es, die Grenzen der Leistungsfähigkeit von LLMs systematisch zu erforschen.
== Zielsetzungen
Die Arbeit verfolgt folgende Ziele:
1. Entwicklung eines Test-Environments zur systematischen Evaluierung von LLM-basierten QA-Systemen.
2. Bewertung der Antwortqualität anhand quantitativer und qualitativer Metriken.
3. Identifikation von Einsatzbereichen, in denen LLM-basierte QA-Systeme einen Mehrwert bieten können.

= Grundlagen und Definitionen
Im folgenden werden die Grundlagen und Funktionsweisen von #acrpl("LLM") sowie die Konzepte von #acr("QA") erläutert.
== LLMs
Dieses Kapitel beleuchtet die Grundlagen und Funktionsweisen von #acrpl("LLM").
=== Architektur und Trainingsparadigmen
Es werden die zugrundeliegenden tiefen neuronalen Netzwerke, die Rolle umfangreicher Trainingsdatensätze und die Auswirkungen verschiedener Trainingsparadigmen erläutert.
=== Stärken und Limitationen
Die Leistungsfähigkeit der Modelle wird kritisch diskutiert – basierend auf Erkenntnissen aus [1] – wobei auch die bekannten Schwächen im Bereich des Faktenwissens thematisiert werden.
=== Stand der Forschung
Ein Überblick über aktuelle Entwicklungen und Forschungsarbeiten im Bereich #acrpl("LLM") bietet die Basis für diese Arbeit.

== Question Answering

Hier wird das Konzept des #acr("QA") umfassend dargestellt.
== Modelltypen: Open Domain vs. Closed Domain
QA-Systeme können in zwei Kategorien unterteilt werden:
- Open Domain QA: Systeme, die mit breit gefächerten, öffentlichen Wissenskorpora (z. B. Wikipedia) arbeiten und allgemeine Fragen beantworten.
- Closed Domain QA: Systeme, die auf spezifische, thematisch eingeschränkte Korpora (z. B. judo-spezifische Literatur) fokussiert sind und detaillierte, fachspezifische Informationen liefern.
== Methoden des QA
Vorstellung der unterschiedlichen Ansätze, von retrievalbasierten Methoden – bei denen relevante Textpassagen aus einem Korpus extrahiert werden – bis hin zu generativen Ansätzen, bei denen Antworten synthetisch erstellt werden.
== Implementierungspipelines
Erläuterung, wie #acr("QA")-Systeme in der Praxis umgesetzt werden. Beispielsweise wird die Integration von BERT- bzw. RoBERTa-basierten Modellen anhand des in [2] vorgestellten Konzepts erläutert.
== Anwendungsfälle
Analyse praktischer Einsatzszenarien, wie etwa im Kundensupport, in Trainingsumgebungen oder im Wissensmanagement, in denen #acr("QA")-Systeme einen signifikanten Mehrwert bieten.

= Metriken und Evaluationsmethoden

Dieses Kapitel beschreibt die Kennzahlen und Verfahren zur Bewertung der #acr("QA")-Systeme.
== Quantitative Kennzahlen
Detaillierte Beschreibung von Metriken wie Genauigkeit, Präzision, Recall und F1-Score zur objektiven Messung der Antwortqualität.
== Qualitative Evaluationsansätze
Erörterung von Verfahren zur inhaltlichen Bewertung, beispielsweise durch Expertenreviews oder den Vergleich mit vorab definierten Referenzantworten.
== Validierung der Ergebnisse
Methoden zur Überprüfung der Reproduzierbarkeit und Aussagekraft der experimentellen Daten werden vorgestellt.

= Konzept

Das konzeptionelle Vorgehen bei der Entwicklung des Test-Environments wird hier erläutert.
== Systemarchitektur
Beschreibung der geplanten Architektur, inklusive der Integration des ausgewählten #acr("LLM") und der Anbindung an den definierten Textkorpus, der aus judo-spezifischen Quellen und ergänzend aus Wikipedia besteht.
== Design des Test-Environments
Ausarbeitung der Strategien zur Generierung von Testfragen und der Festlegung von Referenzantworten. Dabei wird ein flexibles Framework entwickelt, das an verschiedene Evaluationsszenarien angepasst werden kann.
== Use Case Definition
Identifikation potenzieller praktischer Einsatzbereiche, in denen das entwickelte #acr("QA")-System einen signifikanten Mehrwert bieten kann.

= Realisierung

Dieses Kapitel beschreibt die praktische Umsetzung des Konzepts.
== Implementierungsdetails
Die QA-Pipeline wird mithilfe der Huggingface-Transformers-Bibliothek implementiert. Dabei wird ein vortrainiertes Modell, wie z. B. *deepset/roberta-base-squad2*, genutzt. Der Aufbau der Pipeline orientiert sich an einem modifizierten Python-Skript, das an das in [2] gezeigte Colab-Beispiel angelehnt ist. Dieses Skript übernimmt unter anderem folgende Aufgaben:
- Laden des Modells und Tokenizers
- Übergabe von Frage- und Kontextdaten zur Inferenz
- Ausgabe der generierten Antwort samt zugehöriger Metriken
== Software- und Hardwareumgebung
Beschreibung der eingesetzten technischen Ressourcen, wie #acr("GPU")-gestützte Server oder Cloud-Services, die zur Beschleunigung der Inferenz und eventueller Experimente genutzt werden.
== Test- und Validierungsszenarien
Darstellung der durchgeführten Tests, einschließlich der Variation von Fragestellungen (sowohl Open Domain als auch Closed Domain) und der kontinuierlichen Evaluierung der Zwischenergebnisse mittels der zuvor definierten Metriken.
== Datenbeschaffung
Der Textkorpus wird durch die Aggregation verschiedener Quellen erstellt:
- Fachspezifische Literatur: Judo-Regelwerke, Trainingshandbücher und Wettkampfdaten.
- Öffentliche Quellen: Artikel und Einträge von Wikipedia, die durch Web-Scraping oder APIs bezogen werden können.
- Eigene Notizen: Ergänzende, vom Autor erstellte Daten, um den Korpus zu erweitern.

= Evaluierung

In diesem Kapitel werden die experimentellen Ergebnisse analysiert und interpretiert.
== Ergebnisauswertung
Systematische Auswertung der quantitativen und qualitativen Messergebnisse. Ergebnisse werden grafisch (z. B. in Diagrammen) dargestellt.
== Diskussion der Resultate
Kritische Analyse der Resultate im Hinblick auf die definierten Zielsetzungen und identifizierten Limitationen der #acrpl("LLM").
== Vergleich mit bestehenden Ansätzen
Die erarbeiteten Ergebnisse werden mit den in der Literatur beschriebenen Ansätzen (insbesondere @head-to-tail und @qa-bert) verglichen, um den Mehrwert des entwickelten Systems herauszustellen.

= Zusammenfassung und Ausblick

Das abschließende Kapitel fasst die gewonnenen Erkenntnisse zusammen und gibt einen Ausblick auf zukünftige Entwicklungen.
== Schlussfolgerungen
Zusammenfassung der wesentlichen Ergebnisse und Bewertung, inwiefern die definierten Ziele erreicht wurden.
== Empfehlungen für zukünftige Arbeiten
Ableitung von Empfehlungen und potenziellen Erweiterungen für weiterführende Forschungen im Bereich #acr("LLM")-basiertes #acr("QA").
== Reflexion und Ausblick
Kritische Reflexion der Limitationen der durchgeführten Experimente und ein Ausblick auf zukünftige technologische Entwicklungen.