# Icon Assets

Taruh dua file PNG di sini sebelum menjalankan `dart run flutter_launcher_icons`:

| File | Ukuran | Keterangan |
|---|---|---|
| `icon.png` | 1024×1024 | Icon utama (fallback Android lama) |
| `icon_foreground.png` | 1024×1024 | Layer depan adaptive icon (Android 8+); gunakan area aman ~66% tengah |

Setelah file ada, jalankan:
```bash
flutter pub get
dart run flutter_launcher_icons
```
