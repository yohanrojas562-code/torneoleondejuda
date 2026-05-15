<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\SponsorResource;
use App\Models\Sponsor;

class SponsorsController extends Controller
{
    public function __invoke()
    {
        $sponsors = Sponsor::where('is_active', true)
            ->orderBy('order')
            ->orderBy('name')
            ->get();

        return response()->json([
            'sponsors' => SponsorResource::collection($sponsors),
            'type_labels' => Sponsor::typeLabels(),
            'section_titles' => Sponsor::typeSectionTitles(),
        ]);
    }
}
