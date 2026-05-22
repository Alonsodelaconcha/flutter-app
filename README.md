# Flutter App — Mobile Development (Erasmus, ANS Elbląg)

## About
This repository contains my Flutter exercises and final project for the Mobile Development course.

## Learning process
Before building the final project, I worked through the Moodle exercises to get familiar with Flutter:
- Tried the Hello World and layout examples from the lectures
- Built the HTTP exercises from scratch (users list, posts with navigation, search, shopping list, notes, contacts)
- Experimented with StatefulWidget and StatelessWidget to understand state management
- Connected Flutter to Supabase following the lecture examples
- Learned Riverpod for global state management

After getting comfortable with the basics, I used AI assistance to help build the final Schedule app, which combines everything learned: Supabase auth, CRUD operations, navigation, and UI design.

## Projects
- `main.dart` — Supabase Todo app
- `ex1_users.dart` — Users list from JSONPlaceholder API
- `ex2_posts.dart` — Posts list with detail screen
- `ex3_posts_search.dart` — Posts with search filter
- `ex4_shopping.dart` — Shopping list with state management
- `ex5_notes.dart` — Notes app with cards
- `ex6_contacts.dart` — Address book with search
- `schedule_app.dart` — Final project: Class Schedule with Supabase auth

## Supabase exercises
- `supabase_ex1.dart` — Posts list from Supabase with SnackBar
- `supabase_ex2.dart` — Register / Login / Home with Supabase auth
- `supabase_ex3.dart` — Notes CRUD with Supabase
- `supabase_ex4.dart` — Realtime messages with StreamBuilder

## Riverpod exercises
- `riverpod_ex1.dart` — Like button with shared provider
- `riverpod_ex2.dart` — Global username state with live greeting
- `riverpod_ex3.dart` — Quotes from Supabase with search filter
- `riverpod_ex4.dart` — Add quotes to Supabase with auto-refresh

## Tech stack
Flutter · Dart · Supabase · HTTP · Riverpod