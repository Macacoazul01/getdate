# getdate_textfield

A highly customizable, modern date input field for Flutter. It allows users to fill in a date either by typing directly into the field (with automatic masking and validation) or by selecting it from a beautifully animated calendar overlay.

Built with Flutter's modern `OverlayPortal` architecture, it guarantees zero memory leaks and perfect theme inheritance.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=flat)](https://buymeacoffee.com/gian.bettega)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

## ✨ Features

* **Dual Input:** Type the date directly (with `dd/MM/yyyy` masking) or pick it from the calendar.
* **Modern Architecture:** Uses `OverlayPortal` instead of traditional `OverlayEntry` for rock-solid performance, automatic lifecycle management, and accurate context/theme inheritance.
* **Smart Positioning:** The calendar overlay automatically calculates screen space and opens either below or above the text field to prevent clipping.
* **Highly Customizable:** Tweak colors, borders, overlay dimensions, and padding through clean configuration classes (`DateFieldDecorationConfig` and `DateOverlayConfig`).
* **Validation & Debouncing:** Built-in validation ensures dates fall within your specified `firstDate` and `lastDate` ranges, with customizable error messages.

## 📦 Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  getdate_textfield: 