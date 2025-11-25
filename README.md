<h1 align="center">
  <br>
  <p>Tummy hurts</p>
<h4 align="center"> <a href="https://apps.apple.com/us/app/tummy-hurts/id6753219176" target="_blank">Click to see the project in App Store</a></h4>
  <h4 align="center">Let's find out why your tummy is upset
</h4>
  <br>
  <h4 align="center">
   <img src="https://github.com/user-attachments/assets/3ee6f0c1-8a84-42b0-8bf6-122e44b89865" width="350" h="auto"/>
     <img src="https://github.com/user-attachments/assets/671fceda-fda3-492f-99cf-64a2e4eda156" width="350" h="auto"/>
    </h4>
  <h4 align="center">
   <img src="https://github.com/user-attachments/assets/05de2487-6749-4edf-8c89-576bafd55818" width="350" h="auto"/>
     <img src="https://github.com/user-attachments/assets/4c335dfb-071c-48f4-a9f4-b8a2b2bf4930" width="350" h="auto"/>
    </h4>
</h1>

## Overview
* Tummy Hurts is an iOS app for tracking meals, symptoms and finding potential food triggers
* The app lets you quickly log what you eat and how you feel afterwards
* Then it analyzes patterns between ingredients and symptoms over time
* The goal is to give users a clear, visual way to explore "what might be causing my tummy problems?" without pretending to be a medical diagnostic tool

## Features
* Fast meal ingredients & symptom logging
* 4 analysis modes:
  1. Problematic ingredients: top food triggers, ranked by risk level. Ingredients that consistently precede symptoms rise to the top, with suspicion scores based on timing proximity and historical frequency
  2. Safe ingredients: ingredients identified with 0 symptom associations across multiple tracked meals
  3. Specific symptom investigation: select any past symptom to see exactly which ingredients were consumed beforehand, with suspicion scores calculated from timing and historical patterns. Perfect for identifying unexpected triggers
  4. Monthly calendar: for checking possible patterns during each week and month. Why do you have stomach pain each Friday?
* All data is stored locally on the device - nothing is sent to external servers
* Multi- language UI

## Tech stack
* Swift, SwiftUI
* MVVM
* Database in Core Data
* Charts & data visualization: Swift Charts
* Localization
* System/light/dark themes
