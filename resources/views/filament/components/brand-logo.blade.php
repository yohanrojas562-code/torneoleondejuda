@php $logoPath = \App\Models\SiteSetting::get('logo'); @endphp
@if($logoPath)
    <img src="{{ asset('storage/' . $logoPath) }}" alt="León de Judá" class="h-20" style="height: 5rem;" />
@else
    <span class="text-white font-bold text-xl">León de Judá</span>
@endif
