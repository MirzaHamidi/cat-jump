# Cat Jump: kısa proje rehberi

Bu rehber, ana oyun sahnelerini ve katları nerede düzenleyeceğini gösterir.

## Oyun nasıl açılıyor?

`project.godot` oyunu `Scenes/UI/MainMenu.tscn` ile başlatır. Menüde Start seçilince `Scenes/Levels/Run.tscn` açılır. Run; oyun durumunu, tırmanma sahnesini, arayüzü ve karşılaşma katmanlarını bir arada tutar.

Tırmanma sahnesi `Scenes/Levels/ClimbLevel.tscn` içindedir. Kediyle katlara çıkılır; oyun sırasında kuş veya enerji karşılaşması açılabilir. 50. kattaki hedefe ulaşınca ayrı köpek boss sahnesine geçilir. Boss sahnesi bir prototiptir; değerleri ve oynanış dengesi son hâli olarak kabul edilmemelidir.

## Bir katı düzenlemek

`Scenes/Levels/FloorSections/` klasöründe beş sahne vardır:

- `Floors_01_10.tscn` — 1–10. katlar
- `Floors_11_20.tscn` — 11–20. katlar
- `Floors_21_30.tscn` — 21–30. katlar
- `Floors_31_40.tscn` — 31–40. katlar
- `Floors_41_50.tscn` — 41–50. katlar

Godot’ta ilgili bölüm sahnesini aç, örneğin `Floor_016` düğümünü seç. Pencere, balkon veya diğer yerleşimler katın `Traversal` dalındadır. Bir sahne örneğinin içindeki çocukları düzenlemek gerekirse örnek üzerinde **Editable Children / Düzenlenebilir Çocuklar** seçeneğini kullan. Kaydedilen değişiklik, bu bölümü kullanan ana levelde görünür.

Üst katlar mevcut dünya koordinatlarını korur. Bölümü açtığında 2D görünüm boşsa sahne ağacından ilgili katı seçip 2D editörde seçime odaklanabilirsin.

Her bina katında üç hizalı pencere vardır. Katlar arasındaki klima, balkon veya yangın merdiveni birer ara basamaktır; ayrı bir bina katı sayılmaz. Pencere sıraları genellikle 200 piksel aralıklıdır; aradaki basamaklarla yükseliş çoğunlukla 100 pikseldir (zeminden ilk basamağa 106 piksel).

Her katın Inspector’daki `floor_number` değeri ve `RespawnAnchor` noktası kat takibi ve yeniden doğma için kullanılır. 50. kattaki `RooftopGoal`, boss geçişiyle bağlantılıdır. Bunları taşırken bağlantıları kontrol et. Zemin ve platform yerlerini değiştirirsen normal zıplama ile tekrar dene; çarpışma şekilleri görselle aynı şey değildir.

## Temel dosyalar

- `Scenes/Player/Player.tscn` ve `Scripts/Player.gd`: kedi, hareket ve zıplama. `Scripts/PlayerVisual.gd` kedi görsellerini yönetir.
- `Scenes/Gameplay/FloorTier.tscn`: her katın temel sahnesi; kat numarası ve yeniden doğma noktası burada tanımlıdır.
- `Scripts/ClimbLevel.gd`: katları ve yeniden doğma noktalarını bulur, inişleri ve çatıya ulaşmayı takip eder.
- `Scripts/RunState.gd`: o koşunun enerji, can, mevcut/en yüksek kat ve süre verilerini tutar. `Scripts/RunController.gd` tırmanış, karşılaşma ve boss geçişini yönetir.
- `Scenes/Gameplay/Bird.tscn` ve `Scripts/BirdSpawner.gd`: kuş ve ortaya çıkma düzeni. Boru, merdiven, balkon ve diğer çevre sahneleri `Scenes/Assets/Environment/` altındadır.
- `Scenes/UI/Fight.tscn` ve `Scripts/FightController.gd`: sıra tabanlı karşılaşma. `Scenes/UI/HUD.tscn`: koşu sırasındaki göstergeler.
- `Scenes/Boss/DogBoss.tscn` ve `Scripts/Boss/DogBossArena.gd`: gerçek zamanlı köpek bossu ve sahibinin saldırıları.

`Scenes/Levels/` içindeki test ve deneme sahneleri ayrı çalışma alanlarıdır; ana oyunun başlangıç sahnesi olarak düşünme. Bunları taşımadan veya silmeden önce bağlı oldukları dosyaları kontrol et.
