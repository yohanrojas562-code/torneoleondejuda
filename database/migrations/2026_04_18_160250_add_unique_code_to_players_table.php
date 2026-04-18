<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->string('unique_code', 12)->nullable()->unique()->after('id');
        });

        // Generate codes for existing players
        $players = DB::table('players')->whereNull('unique_code')->get();
        foreach ($players as $player) {
            DB::table('players')->where('id', $player->id)->update([
                'unique_code' => 'LDJ-' . strtoupper(Str::random(8)),
            ]);
        }
    }

    public function down(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->dropColumn('unique_code');
        });
    }
};
