const fs = require('fs');
const csv = require('csv-parser');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

let results = [];
fs.createReadStream('абоненты.csv')
   .pipe(csv({ separator: ';' }))
   .on('data', (data) => results.push(data))
   .on('end', () => {
      // ============================= Задание 2.1 ==============================================
      let task1 = results.slice(0);
      task1.map(function (e, i) {
         e['Тип начисления'] == 2
            ? (e.Начислено = (e.Текущее - e.Предыдущее) * 1.52)
            : (e.Начислено = 301.26);
         e['№ строки'] = i + 1; // Иначе столбец '№ строки' в файле Начисления_абоненты.csv почему-то пустой
      });

      const csvWriter = createCsvWriter({
         path: 'Начисления_абоненты.csv',
         header: [
            { id: '№ строки', title: '№ строки' },
            { id: 'Фамилия', title: 'Фамилия' },
            { id: 'Улица', title: 'Улица' },
            { id: '№ дома', title: '№ дома' },
            { id: '№ Квартиры', title: '№ Квартиры' },
            { id: 'Тип начисления', title: 'Тип начисления' },
            { id: 'Предыдущее', title: 'Предыдущее' },
            { id: 'Текущее', title: 'Текущее' },
            { id: 'Начислено', title: 'Начислено' },
         ],
         fieldDelimiter: ';',
         // encoding: 'utf8',
      });
      csvWriter.writeRecords(task1);
      // =====================================================================================================

      // ============================ Задание 2.2 ==============================================================
      let houses = [
         ...new Set(task1.slice(0).map((e) => e.Улица + ' ' + e['№ дома'])),
      ];
      let total = houses.slice(0).map((house) =>
         task1
            .slice(0)
            .filter((e) => e.Улица + ' ' + e['№ дома'] == house)
            .map((e) => e.Начислено)
            .reduce((sum, cur) => sum + cur)
      );
      let task2 = houses.slice(0).map((e, i) => ({
         '№ строки': i + 1,
         Улица: e.split(' ')[0],
         '№ дома': e.split(' ')[1],
         Начислено: total[i],
      }));

      const csvWriter2 = createCsvWriter({
         path: 'Начисления_дома.csv',
         header: [
            { id: '№ строки', title: '№ строки' },
            { id: 'Улица', title: 'Улица' },
            { id: '№ дома', title: '№ дома' },
            { id: 'Начислено', title: 'Начислено' },
         ],
         fieldDelimiter: ';',
      });
      csvWriter2.writeRecords(task2);
   });
