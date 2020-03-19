export interface Location {
	line: number;
	column?: number;
}

export interface UrlLocation extends Location {
	url?: string;
}

export interface LocationWithColumn extends Location {
	column: number;
}

export interface MappedLocation extends LocationWithColumn {
	generated?: LocationWithColumn;
}

export interface Range {
	start: LocationWithColumn;
	end: LocationWithColumn;
}
