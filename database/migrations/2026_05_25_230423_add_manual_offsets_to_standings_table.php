<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Agrega columnas `manual_*` a la tabla `standings` que representan AJUSTES
 * MANUALES persistentes hechos por el admin. Funcionamiento:
 *
 *  - El admin edita la tabla y cambia, por ejemplo, PTS de 3 a 6.
 *  - Al guardar, calculamos: live_points (recálculo desde partidos) = 3
 *    y manual_points = 6 - 3 = 3.
 *  - Guardamos: points = 6 (el final que ve el admin), manual_points = 3.
 *  - Cuando se vuelve a recalcular: nuevos partidos suman +3 a live_points
 *    (queda 6), y points = 6 + manual_points (3) = 9. Así el ajuste manual
 *    no se pierde y los nuevos resultados se acumulan correctamente.
 *
 * Columnas default 0 — los registros existentes simplemente tienen
 * `manual_* = 0` y siguen comportándose igual hasta que el admin haga un
 * ajuste manual.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('standings', function (Blueprint $table) {
            $table->integer('manual_played')->default(0)->after('played');
            $table->integer('manual_won')->default(0)->after('won');
            $table->integer('manual_drawn')->default(0)->after('drawn');
            $table->integer('manual_lost')->default(0)->after('lost');
            $table->integer('manual_goals_for')->default(0)->after('goals_for');
            $table->integer('manual_goals_against')->default(0)->after('goals_against');
            $table->integer('manual_points')->default(0)->after('points');
            $table->integer('manual_yellow_cards')->default(0)->after('yellow_cards');
            $table->integer('manual_blue_cards')->default(0)->after('blue_cards');
            $table->integer('manual_red_cards')->default(0)->after('red_cards');
        });
    }

    public function down(): void
    {
        Schema::table('standings', function (Blueprint $table) {
            $table->dropColumn([
                'manual_played',
                'manual_won',
                'manual_drawn',
                'manual_lost',
                'manual_goals_for',
                'manual_goals_against',
                'manual_points',
                'manual_yellow_cards',
                'manual_blue_cards',
                'manual_red_cards',
            ]);
        });
    }
};
