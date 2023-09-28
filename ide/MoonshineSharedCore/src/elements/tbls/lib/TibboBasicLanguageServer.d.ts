export interface ProjectExplorerItem {
    name: string;
    children?: ProjectExplorerItem[];
    docs?: string;
    enabled?: boolean;
    location?: number;
}
