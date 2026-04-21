<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->integer('home_yellow_cards')->default(0)->after('away_penalty_score');
            $table->integer('home_blue_cards')->default(0)->after('home_yellow_cards');
            $table->integer('home_red_cards')->default(0)->after('home_blue_cards');
            $table->integer('away_yellow_cards')->default(0)->after('home_red_cards');
            $table->integer('away_blue_cards')->default(0)->after('away_yellow_cards');
            $table->integer('away_red_cards')->default(0)->after('away_blue_cards');
        });

        Schema::table('standings', function (Blueprint $table) {
            $table->integer('fair_play_points')->default(0)->after('red_cards');
        });
    }

    public function down(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->dropColumn([
                'home_yellow_cards', 'home_blue_cards', 'home_red_cards',
                'away_yellow_cards', 'away_blue_cards', 'away_red_cards',
            ]);
        });

        Schema::table('standings', function (Blueprint $table) {
            $table->dropColumn('fair_play_points');
        });
    }
};
