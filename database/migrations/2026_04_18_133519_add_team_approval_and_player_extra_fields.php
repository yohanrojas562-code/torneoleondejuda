<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Campos de aprobación para equipos
        Schema::table('teams', function (Blueprint $table) {
            $table->enum('approval_status', ['pending', 'approved', 'rejected'])->default('pending')->after('is_active');
            $table->text('rejection_reason')->nullable()->after('approval_status');
        });

        // Campos extra para jugadores: nombre en dorsal, estatura, peso, es_capitan, solicitud especial
        Schema::table('players', function (Blueprint $table) {
            $table->string('jersey_name', 50)->nullable()->after('jersey_number');
            $table->decimal('height', 5, 2)->nullable()->after('jersey_name');
            $table->decimal('weight', 5, 2)->nullable()->after('height');
            $table->boolean('is_captain')->default(false)->after('weight');
            $table->boolean('special_request')->default(false)->after('is_captain');
            $table->text('special_request_reason')->nullable()->after('special_request');
        });
    }

    public function down(): void
    {
        Schema::table('teams', function (Blueprint $table) {
            $table->dropColumn(['approval_status', 'rejection_reason']);
        });

        Schema::table('players', function (Blueprint $table) {
            $table->dropColumn(['jersey_name', 'height', 'weight', 'is_captain', 'special_request', 'special_request_reason']);
        });
    }
};
