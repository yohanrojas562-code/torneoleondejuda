<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->string('document_type')->nullable()->after('last_name');
            $table->string('eps_certificate')->nullable()->after('photo');
            $table->string('no_eps_consent')->nullable()->after('eps_certificate');
            $table->boolean('has_eps')->default(true)->after('no_eps_consent');
            $table->string('parental_consent')->nullable()->after('has_eps');
            $table->string('church')->nullable()->after('parental_consent');
            $table->enum('approval_status', ['pending', 'approved', 'rejected'])->default('pending')->after('church');
            $table->text('rejection_reason')->nullable()->after('approval_status');
            $table->text('observations')->nullable()->after('rejection_reason');
            $table->integer('total_matches')->default(0)->after('observations');
            $table->integer('total_goals')->default(0)->after('total_matches');
            $table->integer('yellow_cards')->default(0)->after('total_goals');
            $table->integer('blue_cards')->default(0)->after('yellow_cards');
            $table->integer('red_cards')->default(0)->after('blue_cards');
            $table->integer('total_fouls')->default(0)->after('red_cards');
            $table->text('sanctions')->nullable()->after('total_fouls');
        });
    }

    public function down(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->dropColumn([
                'document_type', 'eps_certificate', 'no_eps_consent', 'has_eps',
                'parental_consent', 'church', 'approval_status', 'rejection_reason',
                'observations', 'total_matches', 'total_goals', 'yellow_cards',
                'blue_cards', 'red_cards', 'total_fouls', 'sanctions',
            ]);
        });
    }
};
