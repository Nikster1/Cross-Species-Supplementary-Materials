import pandas as pd
import numpy as np
import os

np.random.seed(42)

df = pd.read_csv("DONOR-METADATA.csv")

ROMAN = {"0": 0, "I": 1, "II": 2, "III": 3, "IV": 4, "V": 5, "VI": 6}
df["Braak_num"] = df["Braak"].str.extract(r"Braak\s+(\w+)")[0].map(ROMAN)

df["PMI"]       = pd.to_numeric(df["PMI"],       errors="coerce")
df["Brain pH"]  = pd.to_numeric(df["Brain pH"],  errors="coerce")
df["RIN"]       = pd.to_numeric(df["RIN"],       errors="coerce")

not_severely_affected = df["Severely Affected Donor"].isna() | (df["Severely Affected Donor"] != "Y")

groups = {
    "AD - Male": (
        (df["Braak_num"] >= 5)
        & (df["Cognitive Status"] == "Dementia")
        & (df["Overall AD neuropathological Change"] == "High")
        & (df["Sex"] == "Male")
        & not_severely_affected
    ),
    "AD - Female": (
        (df["Braak_num"] >= 5)
        & (df["Cognitive Status"] == "Dementia")
        & (df["Overall AD neuropathological Change"] == "High")
        & (df["Sex"] == "Female")
        & not_severely_affected
    ),
    "Control - Male": (
        (df["Braak_num"] == 4)
        & (df["Cognitive Status"] == "No dementia")
        & (df["Overall AD neuropathological Change"].isin(["Not AD", "Low", "Intermediate"]))
        & (df["Sex"] == "Male")
    ),
    "Control - Female": (
        (df["Braak_num"] == 4)
        & (df["Cognitive Status"] == "No dementia")
        & (df["Overall AD neuropathological Change"].isin(["Not AD", "Low", "Intermediate"]))
        & (df["Sex"] == "Female")
    ),
}

cols = ["Donor ID", "Age at Death", "Sex", "Cognitive Status",
        "Overall AD neuropathological Change", "Braak", "Braak_num",
        "PMI", "Brain pH", "RIN"]

results = []
for group, mask in groups.items():
    subset = df.loc[mask, cols].copy()
    subset.insert(0, "Group", group)
    results.append(subset)
    print(f"\n{group} (n={len(subset)}):")
    print(subset["Donor ID"].tolist())

out = pd.concat(results, ignore_index=True)
out = out.drop(columns="Braak_num")

print(f"\nAll donors ({len(out)} total):".center(40, "-"))
print(out.to_string(index=False))


def quality_weight(subset):
    pmi = subset["PMI"].fillna(subset["PMI"].median())
    ph  = subset["Brain pH"].fillna(subset["Brain pH"].median())
    rin = subset["RIN"].fillna(subset["RIN"].median())

    pmi_w = 1 / (pmi + 1)
    ph_w  = ph / ph.max()
    rin_w = rin / rin.max()

    return (pmi_w * ph_w * rin_w).clip(lower=1e-9)


N = min(mask.sum() for mask in groups.values())
N = max(N, 4)

selected = []
for group, mask in groups.items():
    subset = df.loc[mask, cols]

    if "Control" in group:
        npr = {"Not AD": 0, "Low": 1, "Intermediate": 2, "High": 3}
        npath      = subset["Overall AD neuropathological Change"].map(npr)
        braak_dist = (subset["Braak_num"] - 4).abs()
        path_weight = 1 / (braak_dist + npath + 1)
        weight = path_weight * quality_weight(subset)
    else:
        weight = quality_weight(subset)

    selection = subset.sample(n=N, weights=weight.values)
    selection = selection.copy()
    selection.insert(0, "Group", group)
    selected.append(selection)

SELECTIONS = pd.concat(selected, ignore_index=True)
SELECTIONS = SELECTIONS.drop(columns="Braak_num")

print("")
print("")
Break = "SELECTED TABLE"
print(Break.center(110, "-"))
print("")
print(SELECTIONS.to_string(index=False))


os.makedirs("selection information", exist_ok=True)

out.to_csv(os.path.join("selection information", "eligible_pool.csv"), index=False)
SELECTIONS.to_csv(os.path.join("selection information", "selected_donors.csv"), index=False)

summary = SELECTIONS["Group"].value_counts().rename_axis("Group").reset_index(name="n_selected")
summary.to_csv(os.path.join("selection information", "selection_summary.csv"), index=False)

print("\nSaved to 'selection information/':")
print("  eligible_pool.csv, selected_donors.csv, selection_summary.csv")
