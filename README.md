# Linux System Call Wrapper Project

Учебный проект по модификации системного вызова \`open\` в ядре Linux 5.10.

## Что реализовано

1. **Сборка ядра 5.10.235** с исправлениями для GCC 15/C23
2. **Обёртка sys_open** с логированием в kernel log (\`dmesg\`)
3. **UML-диаграммы** архитектуры системных вызовов

## Структура

```
patches/
└── 0001-add-open-wrapper.patch    # Unified diff для fs/open.c
docs/diagrams/
└── project_structure.puml/png     # Артефакты проекта
src/
└── kernel-config                  # .config для воспроизводимой сборки
```
### ![Project Structure](docs/diagrams/project_structure.png)

## Запуск из реестра контейнеров

```bash
docker run --rm -it --device /dev/kvm ghcr.io/valuncilh/syscall-wrapper-linux:5.10.235
```

После загрузки, внутри гостя:
```
cat /etc/alpine-release
dmesg | grep MY_OPEN
```

Exit QEMU: `Ctrl-A` then `X`.

## Лицензия
GPL-2.0 (патчи для ядра)
