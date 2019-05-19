# CrossMetric

## Цель и задачи

   Большинство дорог в российских городах не дружелюбны к пешеходам, велосипедиста, инвалидам.
   Словом, ко всем тем, кто не на машине. Многие автомобилисты (в том числе принимающие решения) в городе
   не верят, что улучшение условий для пешеходов, не приведет к появлению пробок на дорогах.
   
   Нашей целью является устранение этого стереотипа и, как следствие, совершенствование транспортной инфраструктуры.
   
   Для достижения этой цели необходимо было решить следующие задачи:
   
   * Данные о реальной ситуации на дорогах существуют, однако, либо дóроги, либо
     недоступны обычному пользователю. Мы решаем эту задачу, получая видеопоток
     с открытых веб-камер.
   * Мы обрабатываем поток, выделяя траектории машин, автобусов и пешеходов. Эти
     данные усредняются за какое-то время, и мы получаем данные о типичном
     потоке (что не исключает возможности сохранять информацию о различии потока
     в разное время суток, праздничные дни и т.п.)
   * Далее, необходимо смоделировать схему перекрестка и с учётом реального
     потока автомобилей, автобусов и пешеходов на нём. 
   * Мы даём возможность пользователям в игровой форме пробовать различные
     режимы работы светофоров, количество полос, ограничения скорости
     автомобилей, видеть смоделированное движение и получать информацию о
     существенных его характеристиках. Это позволяет найти лучшее решение для
     пешеходов, не приводящее к серьезным заторам и пробкам, и устраняет
     описанный выше стереотип.



### Простота использования

### Масштабируемость

## Техническое описание

### Сбор данных

Сбор информации с перекрестков осуществляется в 2 этапа:
1) Обработка видео для сбора треков

   Детектирование машин и пешеходов осуществляется с помощью нейронной сети [**YOLO**](https://pjreddie.com/darknet/yolo/)(*You only look once*).

<img src="https://github.com/gltronred/peremetrika/raw/master/readme_images/cross_tracking.png" alt="Demo" />

2) Обработка собранных треков, выделение участков въездов\выездов из перекрестка

   Области с машинами и пешеходами передаются в трекер [**Deep SORT**](https://github.com/nwojke/deep_sort). В основе трекинга лежит выделение особенностей у обьектов(*построение дескрипторов*). Трекер предсказывает будущее положение обьектов с помощью фильтра калмана. Построенные дескрипторы позволяют нам продолжать трекать обьект, даже если он был чем-то перекрыт продолжительное время.
   
<img src="https://github.com/gltronred/peremetrika/raw/master/readme_images/cross_processed.png" alt="Demo" />

### Моделирование перекрестка

### Отображение
