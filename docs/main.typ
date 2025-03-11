#import "@preview/clean-dhbw:0.2.1": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#show: clean-dhbw.with(
  // Titel & Art der Arbeit
  title: "Evaluierung von LLM-basierten QA",
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
  abstract: "Diese Arbeit untersucht systematisch die Antwortqualität von LLM-basierten QA-Systemen. Es wird ein neues Test-Environment entwickelt, in dem ein speziell definierter Textkorpus sowie gezielte Variationen der Fragestellungen zur Evaluation herangezogen werden. Ziel ist es, mittels quantitativer Metriken (z. B. Genauigkeit, Präzision, Recall, F1-Score) und qualitativer Analysen die Leistungsfähigkeit der LLM hinsichtlich Korrektheit und Vollständigkeit der generierten Antworten zu bewerten. Die gewonnenen Erkenntnisse sollen die aktuellen Grenzen der Modelle aufzeigen und Ansatzpunkte für deren Optimierung in praktischen Anwendungen liefern.",
  
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

Diese Studienarbeit befasst sich mit der Evaluierung von #acr("LLM")-basiertem #acr("QA"). Dabei wird untersucht, wie #acrpl("LLM") in der Lage sind, natürlich formulierte Fragen (#acr("QA")) basierend auf einem definierten Textkorpus automatisch zu beantworten. Die Ausgangssituation ist geprägt durch den rasanten Fortschritt im Bereich der künstlichen Intelligenz und #acr("NLP"). Trotz der beeindruckenden Leistungsfähigkeit weisen aktuelle Modelle oftmals Defizite in Bezug auf Faktenwissen und Detailgenauigkeit auf. Ziel dieser Arbeit ist es, die Antwortqualität – gemessen an Kriterien wie Korrektheit, Vollständigkeit und Relevanz – systematisch zu bewerten und potenzielle Einsatzbereiche, wie beispielsweise den Kundensupport oder interne Wissensdatenbanken, zu identifizieren. Hierfür wird ein flexibles Test-Environment entwickelt, das verschiedene Evaluationsmethoden kombiniert.

= Einleitung

Dieses Kapitel führt in das Themengebiet ein und legt die Motivation sowie die Problemstellung dar.
== Motivation
Die steigende Nachfrage nach automatisierten Informationssystemen und die rasante Entwicklung von #acrpl("LLM") machen es notwendig, deren Leistungsfähigkeit in praktischen Anwendungen kritisch zu evaluieren.
== Problemstellung
Obwohl #acrpl("LLM") beeindruckende Ergebnisse liefern, bestehen Herausforderungen in der Gewährleistung korrekter und vollständiger Antworten, insbesondere bei fachspezifischen Fragestellungen.
== Zielsetzungen
Die Arbeit definiert konkrete, validierbare Ziele: Die Messung der Antwortqualität anhand standardisierter Metriken und die Identifikation geeigneter Use Cases für den praktischen Einsatz von #acr("QA")-Systemen.

= LLMs

Dieses Kapitel beleuchtet die Grundlagen und Funktionsweisen von #acrpl("LLM").
== Architektur und Trainingsparadigmen
Erläuterung der tiefen neuronalen Netzwerke, die #acrpl("LLM") zugrunde liegen, sowie der Einfluss von Trainingsdaten auf die Modellleistung.
== Stärken und Limitationen
Diskussion der Leistungsfähigkeit und der bekannten Schwächen von #acrpl("LLM"), basierend auf Untersuchungen wie in @head-to-tail.
== Stand der Forschung
Überblick über aktuelle Entwicklungen und Forschungsarbeiten im Bereich #acrpl("LLM"), die als Basis für diese Arbeit dienen.

= Questionanswering

Hier wird das Konzept des #acr("QA") umfassend dargestellt.
== Methoden des QA
Vorstellung der unterschiedlichen Ansätze, von retrievalbasierten bis hin zu generativen Methoden, und deren jeweilige Vor- und Nachteile.
== Implementierungspipelines
Beschreibung, wie #acr("QA")-Systeme in der Praxis umgesetzt werden – exemplarisch wird die Integration von BERT-basierten Modellen, wie im Video @qa-bert gezeigt, erläutert.
== Anwendungsfälle
Analyse praktischer Einsatzszenarien, z. B. im Kundensupport oder Wissensmanagement, in denen #acr("QA")-Systeme einen signifikanten Mehrwert bieten können.

= Metriken und Evaluationsmethoden

Dieses Kapitel beschreibt die Kennzahlen und Methoden zur Bewertung der #acr("QA")-Systeme.
== Quantitative Kennzahlen
Detaillierte Beschreibung von Metriken wie Genauigkeit, Präzision, Recall und F1-Score zur objektiven Messung der Antwortqualität.
== Qualitative Evaluationsansätze
Erörterung von Verfahren zur inhaltlichen Bewertung der Antworten, etwa durch Expertenbewertungen oder Vergleich mit Referenzantworten.
== Validierung der Ergebnisse
Darstellung von Methoden zur Überprüfung der Reproduzierbarkeit und Aussagekraft der experimentellen Daten.

= Konzept

Das konzeptionelle Vorgehen bei der Entwicklung des Test-Environments wird hier erläutert.
== Systemarchitektur
Beschreibung der geplanten Architektur, inklusive der Integration des ausgewählten #acr("LLM") und der Anbindung an den definierten Textkorpus.
== Design des Test-Environments
Ausarbeitung der Strategien zur Generierung von Testfragen und der Festlegung von Referenzantworten. Besonderes Augenmerk liegt auf der Flexibilität des Systems zur Anpassung an verschiedene Evaluationsszenarien.
== Use Case Definition
Identifikation und Beschreibung potenzieller praktischer Einsatzbereiche, in denen das entwickelte #acr("QA")-System einen Mehrwert bieten kann.

= Realisierung

Dieses Kapitel beschreibt die praktische Umsetzung des Konzepts.
== Implementierungsdetails
Erläuterung der Umsetzung der #acr("QA")-Pipeline unter Verwendung moderner Bibliotheken und Frameworks, inklusive Code-Beispielen und Architekturdiagrammen.
== Software- und Hardwareumgebung
Beschreibung der eingesetzten technischen Ressourcen, wie #acr("GPU") und weiterer Infrastrukturkomponenten, die zur Realisierung der Experimente genutzt werden.
== Test- und Validierungsszenarien
Darstellung der durchgeführten Tests, der verwendeten Parametervariationen und der Methode zur kontinuierlichen Evaluierung der Zwischenergebnisse.

= Evaluierung

In diesem Kapitel werden die experimentellen Ergebnisse analysiert und interpretiert.
== Ergebnisauswertung
Systematische Auswertung der quantitativen und qualitativen Messergebnisse. Darstellung der Ergebnisse in Diagrammen und Tabellen zur besseren Vergleichbarkeit.
== Diskussion der Resultate
Kritische Analyse der Ergebnisse im Hinblick auf die ursprünglichen Zielsetzungen und die identifizierten Limitationen der #acrpl("LLM").
== Vergleich mit bestehenden Ansätzen
Vergleich der erarbeiteten Ergebnisse mit den in der Literatur beschriebenen Ansätzen, insbesondere unter Bezugnahme auf @head-to-tail und @qa-bert.

= Zusammenfassung und Ausblick

Das abschließende Kapitel fasst die Erkenntnisse zusammen und gibt einen Ausblick auf zukünftige Entwicklungen.
== Schlussfolgerungen
Zusammenfassung der wesentlichen Ergebnisse und Bewertung, inwiefern die definierten Ziele erreicht wurden.
== Empfehlungen für zukünftige Arbeiten
Ableitung von Empfehlungen und möglichen Erweiterungen für weiterführende Forschungen im Bereich #acr("LLM")-basiertes #acr("QA").
== Reflexion und Ausblick
Kritische Reflexion der Limitationen der durchgeführten Experimente und Ausblick auf zukünftige technologische Entwicklungen.
