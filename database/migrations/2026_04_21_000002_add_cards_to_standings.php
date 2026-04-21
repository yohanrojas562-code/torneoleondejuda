<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('standings', function (Blueprint $table) {
            $table->integer('yellow_cards')->default(0)->after('points');
            $table->integer('blue_cards')->default(0)->after('yellow_cards');
            $table->integer('red_cards')->default(0)->after('blue_cards');
        });
    }

    public function down(): void
    {
        Schema::table('standings', function (Blueprint $table) {
            $table->dropColumn(['yellow_cards', 'blue_cards', 'red_cards']);
        });
    }
};
