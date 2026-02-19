# 🛠️ SatellaOS Tools

A comprehensive collection of utility scripts to customize and manage your SatellaOS system.

<div align="center">

[![Language: English](https://img.shields.io/badge/Language-English-blue)](#-english)
[![Dil: Türkçe](https://img.shields.io/badge/Dil-Türkçe-red)](#-türkçe)

</div>

---

## 📋 Table of Contents

- [English Documentation](#-english)
  - [Available Tools](#available-tools)
  - [Tool Descriptions](#tool-descriptions)
- [Türkçe Dokümantasyon](#-türkçe)
  - [Mevcut Araçlar](#mevcut-araçlar)
  - [Araç Açıklamaları](#araç-açıklamaları)

---

## 🇬🇧 English

### Available Tools

| Tool | Category | Description |
|------|----------|-------------|
| `config-backup.sh` | System | Backup configurations |
| `config-restore.sh` | System | Restore configurations |
| `fonts.sh` | Customization | Font installer (120 fonts) |
| `KVM-Tool.sh` | Virtualization | KVM management |
| `Papirus-color-changer.sh` | Customization | Icon theme customizer |
| `PWA-Installer.sh` | Applications | PWA installer |
| `PWA-Remover.sh` | Applications | PWA remover |
| `satellaos-program-installer-tool.sh` | Applications | Batch program installer |

---

### Tool Descriptions

#### 💾 config-backup.sh
**Configuration Backup Tool**

Backs up your XFCE and LightDM configurations to ensure your system settings are safely preserved.

- **Backup Location:** `$HOME/satellaos-installer/configuration`
- **Backed Up Components:**
  - XFCE desktop environment settings
  - LightDM display manager configuration
- **Use Case:** Before major system changes or updates

---

#### ♻️ config-restore.sh
**Configuration Restore Tool**

Restores previously backed-up XFCE and LightDM configurations.

- **Restore Source:** `$HOME/satellaos-installer/configuration`
- **Features:**
  - Quick settings recovery
  - Revert to previous stable state
- **Use Case:** After system issues or unwanted changes

---

#### 🖋️ fonts.sh
**Font Installation Manager**

Comprehensive font installer with 120 professionally curated fonts.

- **Total Fonts:** 120
- **Categories:**
  - Regional fonts (Latin, Cyrillic, Arabic, etc.)
  - Usage-based selection (coding, design, general)
- **Features:**
  - Easy categorized selection
  - Quick typography customization

---

#### ⚙️ KVM-Tool.sh
**KVM Management Utility**

Enable or disable KVM (Kernel-based Virtual Machine) support.

- **Supported CPUs:**
  - Intel processors
  - AMD processors
- **Use Case:** 
  - Toggle KVM when needed for VirtualBox
  - Manage virtualization requirements
  - Resolve virtualization conflicts

---

#### 🎨 Papirus-color-changer.sh
**Papirus Icon Theme Customizer**

One-click color customization for Papirus icon theme.

- **Framework:** Papirus-folders
- **Color Options:** 25 distinct colors
- **Features:**
  - Instant theme color switching
  - Visual system customization
- **Requirements:** Papirus icon theme installed

---

#### 🌐 PWA-Installer.sh
**Progressive Web App Installer**

Install websites as standalone desktop applications.

- **Supported Browsers:**
  - Brave
  - Chrome
  - Opera
  - Vivaldi
- **Features:**
  - Add websites to start menu
  - Desktop application integration
  - Quick access to web services

---

#### 🗑️ PWA-Remover.sh
**PWA Uninstaller**

Manage and remove installed Progressive Web Apps.

- **Features:**
  - Auto-detect installed PWAs
  - Bulk removal option
  - Individual PWA deletion
- **Interface:** Interactive selection menu

---

#### 🚀 satellaos-program-installer-tool.sh
**Batch Program Installer**

Install multiple programs simultaneously with number-based selection.

- **Available Programs:** 30
- **Features:**
  - Multi-select installation
  - Number-based selection system
  - Time-saving batch operations
- **Use Case:** Fresh system setup or bulk software installation

---

## 🇹🇷 Türkçe

### Mevcut Araçlar

| Araç | Kategori | Açıklama |
|------|----------|----------|
| `config-backup.sh` | Sistem | Yapılandırma yedeği |
| `config-restore.sh` | Sistem | Yapılandırma geri yükleme |
| `fonts.sh` | Özelleştirme | Font yükleyici (120 font) |
| `KVM-Tool.sh` | Sanallaştırma | KVM yönetimi |
| `Papirus-color-changer.sh` | Özelleştirme | Simge teması özelleştirici |
| `PWA-Installer.sh` | Uygulamalar | PWA yükleyici |
| `PWA-Remover.sh` | Uygulamalar | PWA kaldırıcı |
| `satellaos-program-installer-tool.sh` | Uygulamalar | Toplu program yükleyici |

---

### Araç Açıklamaları

#### 💾 config-backup.sh
**Yapılandırma Yedekleme Aracı**

XFCE ve LightDM yapılandırmalarınızı güvenle yedekler.

- **Yedek Konumu:** `$HOME/satellaos-installer/configuration`
- **Yedeklenen Bileşenler:**
  - XFCE masaüstü ortamı ayarları
  - LightDM ekran yöneticisi yapılandırması
- **Kullanım Amacı:** Önemli sistem değişiklikleri veya güncellemeler öncesi

---

#### ♻️ config-restore.sh
**Yapılandırma Geri Yükleme Aracı**

Önceden yedeklenmiş XFCE ve LightDM yapılandırmalarını geri yükler.

- **Geri Yükleme Kaynağı:** `$HOME/satellaos-installer/configuration`
- **Özellikler:**
  - Hızlı ayar kurtarma
  - Önceki kararlı duruma dönüş
- **Kullanım Amacı:** Sistem sorunları veya istenmeyen değişiklikler sonrası

---

#### 🖋️ fonts.sh
**Font Kurulum Yöneticisi**

120 profesyonel olarak seçilmiş font içeren kapsamlı yükleyici.

- **Toplam Font:** 120
- **Kategoriler:**
  - Bölgesel fontlar (Latin, Kiril, Arap vb.)
  - Kullanım amaçlı seçim (kodlama, tasarım, genel)
- **Özellikler:**
  - Kolay kategorize edilmiş seçim
  - Hızlı tipografi özelleştirme

---

#### ⚙️ KVM-Tool.sh
**KVM Yönetim Aracı**

KVM (Kernel-based Virtual Machine) desteğini açıp kapatır.

- **Desteklenen İşlemciler:**
  - Intel işlemciler
  - AMD işlemciler
- **Kullanım Amacı:** 
  - VirtualBox için gerektiğinde KVM'i değiştirme
  - Sanallaştırma gereksinimlerini yönetme
  - Sanallaştırma çakışmalarını çözme

---

#### 🎨 Papirus-color-changer.sh
**Papirus Simge Teması Özelleştirici**

Papirus simge teması için tek tıkla renk özelleştirme.

- **Altyapı:** Papirus-folders
- **Renk Seçenekleri:** 25 farklı renk
- **Özellikler:**
  - Anında tema rengi değişimi
  - Görsel sistem özelleştirme
- **Gereksinimler:** Papirus simge teması kurulu olmalı

---

#### 🌐 PWA-Installer.sh
**Progressive Web App Yükleyici**

Web sitelerini bağımsız masaüstü uygulamaları olarak kurar.

- **Desteklenen Tarayıcılar:**
  - Brave
  - Chrome
  - Opera
  - Vivaldi
- **Özellikler:**
  - Web sitelerini başlat menüsüne ekleme
  - Masaüstü uygulaması entegrasyonu
  - Web hizmetlerine hızlı erişim

---

#### 🗑️ PWA-Remover.sh
**PWA Kaldırıcı**

Yüklü Progressive Web App'leri yönetin ve kaldırın.

- **Özellikler:**
  - Yüklü PWA'ları otomatik tespit
  - Toplu kaldırma seçeneği
  - Tekil PWA silme
- **Arayüz:** Etkileşimli seçim menüsü

---

#### 🚀 satellaos-program-installer-tool.sh
**Toplu Program Yükleyici**

Numara tabanlı seçim ile aynı anda birden fazla program kurun.

- **Mevcut Programlar:** 30
- **Özellikler:**
  - Çoklu seçim kurulumu
  - Numara tabanlı seçim sistemi
  - Zaman kazandıran toplu işlemler
- **Kullanım Amacı:** Yeni sistem kurulumu veya toplu yazılım yüklemesi

---

## 📝 License

This project is part of the SatellaOS ecosystem.

## 👨‍💻 Developer

Developed and maintained by a single developer for SatellaOS users.

---

<div align="center">

**Made with ❤️ for SatellaOS Creator**

</div>
