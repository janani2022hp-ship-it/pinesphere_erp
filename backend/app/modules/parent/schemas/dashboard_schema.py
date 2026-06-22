from pydantic import BaseModel
from typing import List


class SummaryItem(BaseModel):
    label: str
    value: str
    icon: str


class ModuleItem(BaseModel):
    title: str
    items: List[str]


class ParentDashboardResponse(BaseModel):
    role: str
    title: str
    summary: List[SummaryItem]
    modules: List[ModuleItem]
